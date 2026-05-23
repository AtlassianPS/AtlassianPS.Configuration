#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ConvertFrom-QueryString" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "parses query string values to hashtable" {
            $parsed = ConvertFrom-QueryString -Query "?jql=project%3DTEST&max=25&empty="

            $parsed["jql"] | Should -Be "project=TEST"
            $parsed["max"] | Should -Be "25"
            $parsed["empty"] | Should -Be ""
        }

        It "parses query values from URI input" {
            $uri = [Uri]'https://example.test/search?jql=project%3DTEST&max=50'
            $parsed = ConvertFrom-QueryString -Uri $uri

            $parsed["jql"] | Should -Be "project=TEST"
            $parsed["max"] | Should -Be "50"
        }

        It "returns an empty hashtable for non-query strings" {
            $parsed = ConvertFrom-QueryString -Query "not-a-query-value"

            $parsed | Should -BeOfType [Hashtable]
            $parsed.Keys | Should -BeNullOrEmpty
        }

        It "parses raw query strings without a leading question mark" {
            $parsed = ConvertFrom-QueryString -Query "jql=project%3DTEST&max=25"

            $parsed["jql"] | Should -Be "project=TEST"
            $parsed["max"] | Should -Be "25"
        }

        It "accepts query strings from the pipeline" {
            $parsed = "jql=project%3DTEST" | ConvertFrom-QueryString

            $parsed["jql"] | Should -Be "project=TEST"
        }
    }
}

