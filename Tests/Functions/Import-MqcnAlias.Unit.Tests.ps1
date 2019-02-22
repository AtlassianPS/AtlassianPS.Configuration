#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Import-MqcnAlias" -Tag Unit {

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
            $command = Get-Command -Name Import-MqcnAlias

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
