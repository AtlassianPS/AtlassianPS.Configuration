#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force
}

Describe "ConvertTo-Hashtable" -Tag Unit {

    BeforeAll {
    . "$PSScriptRoot/../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope "AtlassianPS.Configuration" {

        #region Mocking
        #endregion Mocking

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name ConvertTo-Hashtable
            }

            It "has a mandatory parameter 'InputObject' of type [PSObject]" {
                $command | Should -HaveParameter "InputObject" -Mandatory -Type [PSObject]
            }
        }

        Context "Behavior checking" {
            BeforeAll {
                $script:pscustomobject = [PSCustomObject]@{
                    a = 1
                    b = 2
                    c = 3
                    d = 4
                    e = 5
                    f = 6
                }
            }

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
