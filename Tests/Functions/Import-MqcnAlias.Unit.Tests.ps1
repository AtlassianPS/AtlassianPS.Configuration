#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Import-MqcnAlias" -Tag Unit {

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
                $script:command = Get-Command -Name Import-MqcnAlias
            }

            It "has a mandatory parameter 'Alias' of type [String]" {
                $command | Should -HaveParameter "Alias" -Mandatory -Type [String]
            }

            It "has a mandatory parameter 'Command' of type [String]" {
                $command | Should -HaveParameter "Command" -Mandatory -Type [String]
            }
        }

        Context "Behavior checking" {

            It "creates an alias in the module's scope" {
                Import-MqcnAlias -Alias "aa" -Command "Microsoft.PowerShell.Management\Get-Item"

                Get-Alias -Name "aa" -Scope "Local" -ErrorAction Ignore | Should -Be $true
            }

            It "does not make the alias available outside of the module" {
                Import-MqcnAlias -Alias "ab" -Command "Microsoft.PowerShell.Management\Get-Item"

                Get-Alias -Name "ab" -Scope "Global" -ErrorAction Ignore | Should -BeNullOrEmpty
                Get-Alias -Name "ab" -Scope "Script" -ErrorAction Ignore | Should -BeNullOrEmpty
            }
        }
    }
}
