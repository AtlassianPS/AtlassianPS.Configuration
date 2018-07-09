#requires -modules BuildHelpers
#requires -modules Pester

Describe "Get-BreadCrumb" -Tag Unit {

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
