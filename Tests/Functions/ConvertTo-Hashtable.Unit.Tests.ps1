#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "ConvertTo-Hashtable" -Tag Unit {

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
        $pscustomobject = [PSCustomObject]@{
            a = 1
            b = 2
            c = 3
            d = 4
            e = 5
            f = 6
        }
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name ConvertTo-Hashtable

            It "has a [PSObject] -InputObject parameter" {
                $command.Parameters.ContainsKey("InputObject")
                $command.Parameters["InputObject"].ParameterType | Should -Be "PSObject"
            }
        }

        Context "Behavior checking" {

            It "converts an [PSCustomObject] to a Hashtable" {
                ConvertTo-Hashtable -InputObject $pscustomobject | Should -BeOfType [Hashtable]
            }

            It "uses all properties as keys" {
                $hashtable = ConvertTo-Hashtable -InputObject $pscustomobject

                $hashtable.Keys | Should -BeIn @("a", "b", "c", "d", "e", "f")

                @($hashtable.Keys).Count | Should -Be 6
                @($hashtable.PSObject.Properties).Count | Should -BeGreaterOrEqual 6

                $pscustomobject.PSObject.Properties.Name | Should -BeIn $hashtable.Keys
            }

            It "allows to pass the PSCustomObejct over the pipeline" {
                ($pscustomobject | ConvertTo-Hashtable) | Should -BeOfType [Hashtable]
            }

            It "casts InputObject implicitly to PSCustomObject" {
                $hash = @{ lorem = "ipsum"}
                ConvertTo-Hashtable -InputObject $hash | Should -BeOfType [Hashtable]
                (ConvertTo-Hashtable -InputObject $hash).Keys | Should -Contain "lorem"

                $date = Get-Date
                ConvertTo-Hashtable -InputObject $date | Should -BeOfType [Hashtable]
                (ConvertTo-Hashtable -InputObject $date).Keys | Should -Contain "DateTime"
            }
        }
    }
}
