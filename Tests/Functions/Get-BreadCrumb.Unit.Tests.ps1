#requires -modules Pester

Describe "Get-BreadCrumb" -Tag Unit {
    BeforeAll {
        Remove-Item -Path Env:\BH*
        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\..\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
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

            It "has a [String] -Delimiter parameter" {
                $command.Parameters.ContainsKey("Delimiter")
                $command.Parameters["Delimiter"].ParameterType | Should Be "String"
            }
        }

        Context "Behavior checking" {

            It "tracks the call stack" {
                $breadCrumb = function1
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Be 'function2 > function1 >  >  > AtlassianPS.Configuration.psm1 > '
            }

            It "allows for customizing of the delimiter" {
                $breadCrumb = Get-BreadCrumb -Delimiter "--> "
                $breadCrumb | Should -Not -BeNullOrEmpty
                $breadCrumb | Should -Be '--> --> AtlassianPS.Configuration.psm1--> '
            }
        }
    }
}
