#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ConvertTo-ParameterHash" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "parses query string values to hashtable" {
            $parsed = ConvertTo-ParameterHash -Query "?jql=project%3DTEST&max=25&empty="

            $parsed["jql"] | Should -Be "project=TEST"
            $parsed["max"] | Should -Be "25"
            $parsed["empty"] | Should -Be ""
        }
    }
}

