#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force

    $script:module = Get-Module $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix
    $script:testFiles = Get-ChildItem $PSScriptRoot -Include "*.Tests.ps1" -Recurse
    $script:loadedNamespace = [AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object {
        $_.IsPublic -and $_.Namespace -eq 'AtlassianPS'
    }
    $script:publicFunctionFiles = (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName
    $script:privateFunctionFiles = (Get-ChildItem "$env:BHModulePath/Private/*.ps1" -File).BaseName
    $script:exportedFunctionNames = @($script:module.ExportedFunctions.Keys)
    $script:normalizedExportedFunctions = foreach ($functionName in $script:exportedFunctionNames) {
        if ($script:modulePrefix -and $functionName -like "*-$script:modulePrefix*") {
            $functionName -replace "-$script:modulePrefix", '-'
        }
        else {
            $functionName
        }
    }
}

Describe "General project validation" -Tag Unit {
    Describe "Public functions" {
        Context "Function <_>" -ForEach $publicFunctionFiles {
            BeforeAll {
                $script:functionName = $_
            }

            It "has a test file" {
                $expectedTestFile = "$functionName.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "is exported" {
                $normalizedExportedFunctions | Should -Contain $functionName
            }
        }
    }

    Describe "Private functions" {
        It "has private functions" {
            $privateFunctionFiles.Count | Should -BeGreaterThan 0
        }

        Context "Function <_>" -ForEach $privateFunctionFiles {
            BeforeAll {
                $script:functionName = $_
            }

            It "has a test file" {
                $expectedTestFile = "$functionName.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "is loaded in the module" {
                $commandInModule = $module.Invoke({ Get-Command -Name $args[0] -ErrorAction SilentlyContinue }, $functionName)
                $commandInModule | Should -Not -BeNullOrEmpty -Because "private function '$functionName' should be loaded"
            }

            It "is not exported" {
                $normalizedExportedFunctions | Should -Not -Contain $functionName
            }
        }
    }

    Describe "Classes" {
        Context "Class <_>" -ForEach ($loadedNamespace | Where-Object IsClass | ForEach-Object FullName) {
            BeforeAll {
                $script:className = $_
            }

            It "has a test file" {
                $expectedTestFile = "$className.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Describe "Enumerations" {
        Context "Enum <_>" -ForEach ($loadedNamespace | Where-Object IsEnum | ForEach-Object FullName) {
            BeforeAll {
                $script:enumName = $_
            }

            It "has a test file" {
                $expectedTestFile = "$enumName.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Describe "Project structure" {
        It "has a README" {
            Test-Path "$env:BHProjectPath/README.md" | Should -BeTrue
        }

        It "defines the homepage frontmatter in the README" {
            "$env:BHProjectPath/README.md" | Should -FileContentMatchExactly "layout: module"
            "$env:BHProjectPath/README.md" | Should -FileContentMatchExactly "permalink: /module/$env:BHProjectName/"
        }

        It "uses the MIT license" {
            Test-Path "$env:BHProjectPath/LICENSE" | Should -BeTrue
            "$env:BHProjectPath/LICENSE" | Should -FileContentMatchExactly "MIT License"
            "$env:BHProjectPath/LICENSE" | Should -FileContentMatch "Copyright \(c\) 20\d{2} AtlassianPS"
        }

        It "has a .gitignore" {
            Test-Path "$env:BHProjectPath/.gitignore" | Should -BeTrue
        }

        It "has a .gitattributes" {
            Test-Path "$env:BHProjectPath/.gitattributes" | Should -BeTrue
        }

        It "only exports functions from the Public folder" {
            foreach ($exportedFunctionName in $normalizedExportedFunctions) {
                $publicFunctionFiles | Should -Contain $exportedFunctionName -Because "exported function '$exportedFunctionName' should have a corresponding file in Public/"
            }
        }

        It "exports every public function file" {
            foreach ($publicFunction in $publicFunctionFiles) {
                $normalizedExportedFunctions | Should -Contain $publicFunction
            }
        }
    }
}
