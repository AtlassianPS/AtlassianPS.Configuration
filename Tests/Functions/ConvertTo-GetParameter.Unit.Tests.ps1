#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ConvertTo-GetParameter" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "builds query-string format from hashtable" {
            $query = ConvertTo-GetParameter -InputObject ([Ordered]@{
                    jql = "project=TEST"
                    max = "25"
                })

            $query | Should -Match '^\?'
            $query | Should -Match 'jql='
            $query | Should -Match 'max='
        }
    }
}

