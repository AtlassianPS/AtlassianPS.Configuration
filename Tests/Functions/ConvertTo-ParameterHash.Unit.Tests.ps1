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

        It "parses query values from URI input" {
            $uri = [Uri]'https://example.test/search?jql=project%3DTEST&max=50'
            $parsed = ConvertTo-ParameterHash -Uri $uri

            $parsed["jql"] | Should -Be "project=TEST"
            $parsed["max"] | Should -Be "50"
        }

        It "returns an empty hashtable for non-query strings" {
            $parsed = ConvertTo-ParameterHash -Query "jql=project%3DTEST"

            $parsed | Should -BeOfType [Hashtable]
            $parsed.Keys | Should -BeNullOrEmpty
        }
    }
}

