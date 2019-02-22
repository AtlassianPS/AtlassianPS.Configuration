#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "ConvertTo-Hashtable" -Tag Unit {

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

            It "has a mandatory parameter 'InputObject' of type [PSObject]" {
                $command | Should -HaveParameter "InputObject" -Mandatory -Type [PSObject]
            }
        }

        Context "Behavior checking" {

            It "converts an [PSCustomObject] to a Hashtable" {
                ConvertTo-Hashtable -InputObject $pscustomobject | Should -BeOfType [Hashtable]
            }

            It "uses all properties as keys" {
                $hashtable = ConvertTo-Hashtable -InputObject $pscustomobject

                $hashtable.Keys | Should -BeIn @("a", "b", "c", "d", "e", "f")

                $hashtable.Keys | Should -HaveCount 6
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
