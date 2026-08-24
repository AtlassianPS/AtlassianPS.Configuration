#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe "Get-BreadCrumb" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name Get-BreadCrumb
            }

            It "has a parameter 'Delimiter' of type [String] with a default value ' > '" {
                $command | Should -HaveParameter "Delimiter" -Type [String] -DefaultValue " > "
            }
        }

        Context "Behavior checking" {
            It "tracks the call stack" {
                $breadCrumb = & {
                    function function1 { function2 }
                    function function2 { Get-BreadCrumb }
                    function1
                }
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Match '^function2 > function1 > ( > )*AtlassianPS\.Configuration\.psm1 > '
            }

            It "allows for customizing of the delimiter" {
                $breadCrumb = Get-BreadCrumb -Delimiter "--> "
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Match '^--> (-->\s*)*AtlassianPS\.Configuration\.psm1-->\s*'
            }
        }
    }
}
