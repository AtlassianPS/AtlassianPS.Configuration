#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "WriteError" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
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
