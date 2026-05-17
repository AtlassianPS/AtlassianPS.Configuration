#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ThrowError" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name ThrowError
            }

            It "has a [System.Management.Automation.PSCmdlet] -Cmdlet parameter" {
                $command.Parameters.ContainsKey("Cmdlet")
                $command.Parameters["Cmdlet"].ParameterType | Should -Be "System.Management.Automation.PSCmdlet"
            }

            It "has a [System.Exception] -Exception parameter" {
                $command.Parameters.ContainsKey("Exception")
                $command.Parameters["Exception"].ParameterType | Should -Be "System.Exception"
            }

            It "has a [String] -ExceptionType parameter" {
                $command.Parameters.ContainsKey("ExceptionType")
                $command.Parameters["ExceptionType"].ParameterType | Should -Be "String"
            }

            It "has a [String] -Message parameter" {
                $command.Parameters.ContainsKey("Message")
                $command.Parameters["Message"].ParameterType | Should -Be "String"
            }

            It "has a [System.Object] -TargetObject parameter" {
                $command.Parameters.ContainsKey("TargetObject")
                $command.Parameters["TargetObject"].ParameterType | Should -Be "System.Object"
            }

            It "has a [String] -ErrorId parameter" {
                $command.Parameters.ContainsKey("ErrorId")
                $command.Parameters["ErrorId"].ParameterType | Should -Be "String"
            }

            It "has a [System.Management.Automation.ErrorCategory] -Category parameter" {
                $command.Parameters.ContainsKey("Category")
                $command.Parameters["Category"].ParameterType | Should -Be "System.Management.Automation.ErrorCategory"
            }

            It "has a [System.Management.Automation.ErrorRecord] -ErrorRecord parameter" {
                $command.Parameters.ContainsKey("ErrorRecord")
                $command.Parameters["ErrorRecord"].ParameterType | Should -Be "System.Management.Automation.ErrorRecord"
            }
        }

        Context "Behavior checking" { }
    }
}
