#requires -modules Pester

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Import-Module BuildHelpers
        Remove-Item -Path Env:\BH*
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    $module = Get-Module $env:BHProjectName
    $testFiles = Get-ChildItem $PSScriptRoot -Include "*.Tests.ps1" -Recurse

    Context "Public functions" {
        $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1").BaseName

        foreach ($function in $publicFunctions) {

            It "has a test file for $function" {
                $expectedTestFile = "$function.Unit.Tests.ps1"

                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "is exported" {
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

            It "is not exported" {
                $expectedFunctionName = $function -replace "\-", "-$($module.Prefix)"

                $module.ExportedCommands.keys | Should -Not -Contain $expectedFunctionName
            }
        }
    }

    Context "Classes" {

        foreach ($class in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsClass)) {
            It "has a test file for $class" {
                $expectedTestFile = "$class.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Context "Enumeration" {

        foreach ($enum in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsEnum)) {
            It "has a test file for $enum" {
                $expectedTestFile = "$enum.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Context "Project stucture" {
        $publicFunctions = (Get-Module -Name $env:BHProjectName).ExportedCommands.Keys

        It "has all the public functions as a file in '$env:BHProjectName/Public'" {
            foreach ($function in $publicFunctions) {
                $function = $function.Replace((Get-Module -Name $env:BHProjectName).Prefix,'')

                (Get-ChildItem "$env:BHModulePath/Public").BaseName | Should -Contain $function
            }
        }
    }
}
