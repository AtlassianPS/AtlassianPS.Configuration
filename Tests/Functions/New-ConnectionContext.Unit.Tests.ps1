#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Nonsecret unit-test token fixture.')]
param()

Describe 'New-ConnectionContext' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"

        $script:moduleToTest = Initialize-TestEnvironment
        function Register-TestConnection {
            param(
                [String]$Name,

                [String]$Product = 'Jira',

                [Switch]$Default
            )

            $candidate = New-AtlassianConnectionContext -Name $Name -Product $Product -BaseUri https://jira.example.com -PersonalAccessToken original
            $candidate.SetValidationResult('Server', 'test-user')
            Register-AtlassianConnection -Connection $candidate -Default:$Default
        }
    }

    BeforeEach {
        Get-AtlassianConnection | Disconnect-AtlassianConnection
        Mock Save-Configuration { throw 'Lifecycle must not save profiles.' } -ModuleName AtlassianPS.Configuration
    }

    AfterEach {
        Get-AtlassianConnection | Disconnect-AtlassianConnection
        Should -Invoke Save-Configuration -ModuleName AtlassianPS.Configuration -Times 0 -Exactly
    }

    It 'normalizes string and secure tokens without disposing caller input' {
        $secure = ConvertTo-SecureString 'private-sentinel' -AsPlainText -Force
        foreach ($token in @('private-sentinel', $secure)) {
            $context = New-AtlassianConnectionContext -Name work -Product Jira -BaseUri https://jira.example.com -PersonalAccessToken $token

            $context.GetAuthorizationHeader() | Should -Be 'Bearer private-sentinel'
            ($context | Format-List * | Out-String) | Should -Not -Match 'private-sentinel'
            $context.Dispose()
        }
        $secure.Length | Should -BeGreaterThan 0
    }

    It 'rejects empty, coerced and conflicting authentication' {
        foreach ($token in @('', 42, $null)) {
            {
                New-AtlassianConnectionContext -Name work -Product Jira -BaseUri https://jira.example.com -PersonalAccessToken $token
            } | Should -Throw
        }
        {
            New-AtlassianConnectionContext -Name work -Product Jira -BaseUri https://jira.example.com -Anonymous -PersonalAccessToken 'sentinel'
        } | Should -Throw
    }

    It 'rejects unsafe SiteUri values: <SiteUri>' -ForEach @(
        @{ SiteUri = [Uri]::new('/jira', [UriKind]::Relative) }
        @{ SiteUri = [Uri]'ftp://jira.example.com' }
        @{ SiteUri = [Uri]'https://fixture-user:fixture-password@jira.example.com' }
        @{ SiteUri = [Uri]'https://jira.example.com?token=fixture-token' }
        @{ SiteUri = [Uri]'https://jira.example.com#fixture-fragment' }
    ) {
        {
            New-AtlassianConnectionContext -Product Jira -BaseUri https://jira.example.com -SiteUri $SiteUri -Anonymous
        } | Should -Throw 'SiteUri must be an absolute HTTP(S) product endpoint without user information, query or fragment.'
    }

    It 'preserves an accepted SiteUri context path and permits an absent site' {
        foreach ($siteUri in @([Uri]'https://jira.example.com/jira', $null)) {
            $context = New-AtlassianConnectionContext -Product Jira -BaseUri https://jira.example.com/jira -SiteUri $siteUri -Anonymous

            $context.SiteUri | Should -Be $siteUri
            $context.Dispose()
        }
    }

    It 'keeps the authentication email independent of the validated account ID' {
        $context = New-AtlassianConnectionContext -Name cloud -Product Jira -BaseUri https://jira.example.com -EmailAddress me@example.com -ApiToken sentinel
        $context.SetValidationResult('Cloud', 'account-id')
        $decoded = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($context.GetAuthorizationHeader().Substring(6)))

        $decoded | Should -Be 'me@example.com:sentinel'
        $context.Username | Should -Be 'account-id'
        $context.Dispose()
    }
}
