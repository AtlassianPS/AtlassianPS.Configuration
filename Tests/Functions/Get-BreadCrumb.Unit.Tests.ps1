#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-BreadCrumb" -Tag Unit {

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
        function function1 { function2 }
        function function2 { Get-BreadCrumb }
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Get-BreadCrumb

            It "has a parameter 'Delimiter' of type [String] with a default value ' > '" {
                $command | Should -HaveParameter "Delimiter" -Type [String] -DefaultValue " > "
            }
        }

        Context "Behavior checking" {

            It "tracks the call stack" {
                $breadCrumb = function1
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Match '^function2 > function1 >  >  > AtlassianPS.Configuration.psm1 > '
            }

            It "allows for customizing of the delimiter" {
                $breadCrumb = Get-BreadCrumb -Delimiter "--> "
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Match '^--> --> AtlassianPS.Configuration.psm1--> '
            }
        }
    }
}
