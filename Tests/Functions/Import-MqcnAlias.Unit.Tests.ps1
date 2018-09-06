#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "Import-MqcnAlias" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/../..").Path
        if ($projectRoot -like "*Release") {
            $projectRoot = (Resolve-Path "$projectRoot/..").Path
        }

        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

        $env:BHManifestToTest = $env:BHPSModuleManifest
        $script:isBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
        if ($script:isBuild) {
            $Pattern = [regex]::Escape($env:BHProjectPath)

            $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
            $env:BHManifestToTest = $env:BHBuildModuleManifest
        }

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    InModuleScope $env:BHProjectName {

        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Import-MqcnAlias

            It "has a [String] -Alias parameter" {
                $command.Parameters.ContainsKey("Alias")
                $command.Parameters["Alias"].ParameterType | Should Be "String"
            }

            It "has a [String] -Command parameter" {
                $command.Parameters.ContainsKey('Command')
                $command.Parameters["Command"].ParameterType | Should Be "String"
            }
        }

        Context "Behavior checking" {

            It "creates an alias in the module's scope" {
                Import-MqcnAlias -Alias "aa" -Command "Microsoft.PowerShell.Management\Get-Item"

                Get-Alias -Name "aa" -Scope "Local" -ErrorAction Ignore | Should Be $true
            }

            It "does not make the alias available outside of the module" {
                Import-MqcnAlias -Alias "ab" -Command "Microsoft.PowerShell.Management\Get-Item"

                Get-Alias -Name "ab" -Scope "Global" -ErrorAction Ignore | Should BeNullOrEmpty
                Get-Alias -Name "ab" -Scope "Script" -ErrorAction Ignore | Should BeNullOrEmpty
            }
        }
    }
}
