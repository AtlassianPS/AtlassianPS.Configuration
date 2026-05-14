#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -Force
    Invoke-InitTest $PSScriptRoot
    Import-Module $env:BHManifestToTest -Force

    $script:module = Get-Module $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix
    $script:testFiles = Get-ChildItem $PSScriptRoot -Include "*.Tests.ps1" -Recurse
    $script:loadedNamespace = [AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsPublic
    $script:publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1").BaseName
    $script:privateFunctions = (Get-ChildItem "$env:BHModulePath/Private/*.ps1").BaseName
}

Describe "General project validation" -Tag Build {
    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot
        Import-Module $env:BHManifestToTest -Force
    }

    AfterAll {
        Invoke-TestCleanup
    }

    Context "Public function <_>" -ForEach $publicFunctions {
        It "has a test file" {
            $expectedTestFile = "$_.Unit.Tests.ps1"
            $testFiles.Name | Should -Contain $expectedTestFile
        }

        It "is exported by module manifest" {
            $expectedFunctionName = if ($modulePrefix) {
                $_ -replace "-", "-$modulePrefix"
            }
            else {
                $_
            }
            $module.ExportedFunctions.Keys | Should -Contain $expectedFunctionName
        }
    }

    Context "Private function <_>" -ForEach $privateFunctions {
        It "has a test file" {
            $expectedTestFile = "$_.Unit.Tests.ps1"
            $testFiles.Name | Should -Contain $expectedTestFile
        }

        It "is not exported by module manifest" {
            $module.ExportedFunctions.Keys | Should -Not -Contain $_
        }
    }

    Context "Class <_>" -ForEach ($loadedNamespace | Where-Object IsClass) {
        It "has a test file" {
            $expectedTestFile = "$_.Unit.Tests.ps1"
            $testFiles.Name | Should -Contain $expectedTestFile
        }
    }

    Context "Enumeration <_>" -ForEach ($loadedNamespace | Where-Object IsEnum) {
        It "has a test file" {
            $expectedTestFile = "$_.Unit.Tests.ps1"
            $testFiles.Name | Should -Contain $expectedTestFile
        }
    }

    Context "Project stucture" {
        It "has a README" {
            Test-Path "$env:BHProjectPath/README.md" | Should -Be $true
        }

        It "defines the homepage's frontmatter in the README" {
            Get-Content "$env:BHProjectPath/README.md" | Should -Not -BeNullOrEmpty
            "$env:BHProjectPath/README.md" | Should -FileContentMatchExactly "layout: module"
            "$env:BHProjectPath/README.md" | Should -FileContentMatchExactly "permalink: /module/$env:BHProjectName/"
        }

        It "uses the MIT license" {
            Test-Path "$env:BHProjectPath/LICENSE" | Should -Be $true
            Get-Content "$env:BHProjectPath/LICENSE" | Should -Not -BeNullOrEmpty
            "$env:BHProjectPath/LICENSE" | Should -FileContentMatchExactly "MIT License"
            "$env:BHProjectPath/LICENSE" | Should -FileContentMatch "Copyright \(c\) 20\d{2} AtlassianPS"

        }

        It "has a .gitignore" {
            Test-Path "$env:BHProjectPath/.gitignore" | Should -Be $true
        }

        It "has a .gitattributes" {
            Test-Path "$env:BHProjectPath/.gitattributes" | Should -Be $true
        }

        It "exports every public function file" {
            $exportedFunctionNames = @((Get-Module -Name $env:BHProjectName).ExportedFunctions.Keys)
            $normalizedExportedFunctions = foreach ($functionName in $exportedFunctionNames) {
                if ($modulePrefix -and $functionName -like "*-$modulePrefix*") {
                    $functionName -replace "-$modulePrefix", '-'
                }
                else {
                    $functionName
                }
            }

            foreach ($publicFunction in (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName) {
                $normalizedExportedFunctions | Should -Contain $publicFunction
            }
        }
    }
}
