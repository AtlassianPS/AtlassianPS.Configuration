#requires -modules BuildHelpers
#requires -modules Pester

Describe "General project validation" -Tag Build {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $module = Get-Module $env:BHProjectName
    $testFiles = Get-ChildItem $PSScriptRoot -Include "*.Tests.ps1" -Recurse
    $loadedNamespace = [AtlassianPS.ServerData].Assembly.GetTypes() |
        Where-Object IsPublic

    Context "Public functions" {
        $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1").BaseName

        foreach ($function in $publicFunctions) {

            It "has a test file for $function" {
                $expectedTestFile = "$function.Unit.Tests.ps1"

                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "exports $function" {
                $expectedFunctionName = $function -replace "\-", "-$($module.Prefix)"

                $module.ExportedCommands.keys | Should -Contain $expectedFunctionName
            }
        }
    }

    Context "Private functions" {
        $privateFunctions = (Get-ChildItem "$env:BHModulePath/Private/*.ps1").BaseName

        foreach ($function in $privateFunctions) {

            It "has a test file for $function" {
                $expectedTestFile = "$function.Unit.Tests.ps1"

                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "does not export $function" {
                $expectedFunctionName = $function -replace "\-", "-$($module.Prefix)"

                $module.ExportedCommands.keys | Should -Not -Contain $expectedFunctionName
            }
        }
    }

    Context "Classes" {

        foreach ($class in ($loadedNamespace | Where-Object IsClass)) {
            It "has a test file for $class" {
                $expectedTestFile = "$class.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Context "Enumeration" {

        foreach ($enum in ($loadedNamespace | Where-Object IsEnum)) {
            It "has a test file for $enum" {
                $expectedTestFile = "$enum.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
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

        It "has all the public functions as a file in '$env:BHProjectName/Public'" {
            $publicFunctions = (Get-Module -Name $env:BHProjectName).ExportedCommands.Keys

            foreach ($function in $publicFunctions) {
                $function = $function.Replace((Get-Module -Name $env:BHProjectName).Prefix, '')

                (Get-ChildItem "$env:BHModulePath/Public").BaseName | Should -Contain $function
            }
        }
    }
}
