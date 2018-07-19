#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "WriteError" -Tag Unit {

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

        Import-Module "$env:BHProjectPath/Tools/build.psm1"

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
            $command = Get-Command -Name WriteError

            It "has a [System.Management.Automation.PSCmdlet] -Cmdlet parameter" {
                $command.Parameters.ContainsKey("Cmdlet")
                $command.Parameters["Cmdlet"].ParameterType | Should Be "System.Management.Automation.PSCmdlet"
            }

            It "has a [System.Exception] -Exception parameter" {
                $command.Parameters.ContainsKey("Exception")
                $command.Parameters["Exception"].ParameterType | Should Be "System.Exception"
            }

            It "has a [String] -ExceptionType parameter" {
                $command.Parameters.ContainsKey("ExceptionType")
                $command.Parameters["ExceptionType"].ParameterType | Should Be "String"
            }

            It "has a [String] -Message parameter" {
                $command.Parameters.ContainsKey("Message")
                $command.Parameters["Message"].ParameterType | Should Be "String"
            }

            It "has a [System.Object] -TargetObject parameter" {
                $command.Parameters.ContainsKey("TargetObject")
                $command.Parameters["TargetObject"].ParameterType | Should Be "System.Object"
            }

            It "has a [String] -ErrorId parameter" {
                $command.Parameters.ContainsKey("ErrorId")
                $command.Parameters["ErrorId"].ParameterType | Should Be "String"
            }

            It "has a [System.Management.Automation.ErrorCategory] -Category parameter" {
                $command.Parameters.ContainsKey("Category")
                $command.Parameters["Category"].ParameterType | Should Be "System.Management.Automation.ErrorCategory"
            }

            It "has a [System.Management.Automation.ErrorRecord] -ErrorRecord parameter" {
                $command.Parameters.ContainsKey("ErrorRecord")
                $command.Parameters["ErrorRecord"].ParameterType | Should Be "System.Management.Automation.ErrorRecord"
            }
        }

        Context "Behavior checking" { }
    }
}
