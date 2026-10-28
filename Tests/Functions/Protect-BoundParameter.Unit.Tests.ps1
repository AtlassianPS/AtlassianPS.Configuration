#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe "Protect-BoundParameter" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    It "keeps the redaction helper private" {
        (Get-Module AtlassianPS.Configuration).ExportedFunctions.Keys | Should -Not -Contain 'Protect-BoundParameter'
        Get-Command Protect-AtlassianBoundParameter -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "redacts sensitive names regardless of casing" -ForEach @(
            @{ Name = 'Credential' }
            @{ Name = 'PASSWORD' }
            @{ Name = 'ApiToken' }
            @{ Name = 'SecretValue' }
            @{ Name = 'Cookie' }
            @{ Name = 'Authorization' }
            @{ Name = 'Headers' }
            @{ Name = 'Body' }
        ) {
            $parameters = @{ $Name = 'sentinel-secret' }

            $sanitized = Protect-BoundParameter -BoundParameters $parameters

            $sanitized[$Name] | Should -Be '[REDACTED]'
            $parameters[$Name] | Should -Be 'sentinel-secret'
        }

        It "returns an ordered copy and preserves safe scalar types" {
            $parameters = [Ordered]@{
                Key     = 'TEST-1'
                Count   = 7
                Enabled = $true
                Force   = [Switch]$false
                Empty   = ''
                Missing = $null
            }

            $sanitized = Protect-BoundParameter -BoundParameters $parameters

            $sanitized | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            [Object]::ReferenceEquals($sanitized, $parameters) | Should -BeFalse
            ($sanitized.Keys -join ',') | Should -Be ($parameters.Keys -join ',')
            foreach ($key in 'Key', 'Count', 'Enabled', 'Force', 'Empty') {
                $sanitized[$key] | Should -Be $parameters[$key]
                $sanitized[$key].GetType() | Should -Be $parameters[$key].GetType()
            }
            $sanitized.Contains('Missing') | Should -BeTrue
            $sanitized.Missing | Should -BeNullOrEmpty
            $sanitized.Key = 'CHANGED'
            $parameters.Key | Should -Be 'TEST-1'
        }

        It "redacts credentials and secure strings under ordinary names" {
            $secret = [SecureString]::new()
            $secret.AppendChar('x')
            $credential = [PSCredential]::new('sentinel-user', $secret)
            $parameters = @{ First = $secret; Second = $credential }

            $sanitized = Protect-BoundParameter -BoundParameters $parameters

            $sanitized.First | Should -Be '[REDACTED]'
            $sanitized.Second | Should -Be '[REDACTED]'
            [Object]::ReferenceEquals($parameters.First, $secret) | Should -BeTrue
            [Object]::ReferenceEquals($parameters.Second, $credential) | Should -BeTrue
            $secret.Length | Should -Be 1
        }

        It "removes URI user information, queries and fragments without changing inputs" {
            $parameters = @{
                Absolute = [Uri]'https://sentinel-user:sentinel-password@example.com:8443/path%20name?token=sentinel-query#sentinel-fragment'
                Relative = [Uri]::new('/rest/api/2/issue?token=sentinel-relative#sentinel-fragment', [UriKind]::Relative)
            }

            $sanitized = Protect-BoundParameter -BoundParameters $parameters

            $sanitized.Absolute | Should -Be 'https://example.com:8443/path%20name'
            $sanitized.Relative | Should -Be '/rest/api/2/issue'
            $parameters.Absolute.UserInfo | Should -Be 'sentinel-user:sentinel-password'
            $parameters.Relative.OriginalString | Should -Match 'sentinel-relative'
        }

        It "does not serialize complex objects or invoke their string conversion" {
            $value = [PSCustomObject]@{ Value = 'sentinel-secret' }
            $value | Add-Member -MemberType ScriptMethod -Name ToString -Value { throw 'Unsafe string conversion' } -Force
            $parameters = @{ Object = $value; Array = @('sentinel-array'); Dictionary = @{ Value = 'sentinel-dictionary' } }

            $sanitized = Protect-BoundParameter -BoundParameters $parameters

            $sanitized.Object | Should -Be '[System.Management.Automation.PSCustomObject]'
            $sanitized.Array | Should -Be '[System.Object[]]'
            $sanitized.Dictionary | Should -Be '[System.Collections.Hashtable]'
            [Object]::ReferenceEquals($parameters.Object, $value) | Should -BeTrue
            $parameters.Array[0] | Should -Be 'sentinel-array'
            $parameters.Dictionary.Value | Should -Be 'sentinel-dictionary'
        }

        It "accepts an empty dictionary" {
            $sanitized = Protect-BoundParameter -BoundParameters @{}

            $sanitized | Should -BeOfType [System.Collections.IDictionary]
            $sanitized.Count | Should -Be 0
        }
    }
}
