#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'Disconnect-Connection' -Tag Unit {
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

    It 'invalidates retained handles and clears without promoting a default' {
        $first = Register-TestConnection work
        $second = Register-TestConnection admin
        $first | Disconnect-AtlassianConnection

        $first.State | Should -Be 'Disconnected'
        Get-AtlassianConnection -Product Jira -Default | Should -BeNullOrEmpty
        { Resolve-AtlassianRequestContext -Product Jira -Connection $first } | Should -Throw

        $third = Register-TestConnection work

        $third.Id | Should -BeGreaterThan $second.Id
        $third.InstanceId | Should -Not -Be $first.InstanceId
        (Get-AtlassianConnection -Product Jira -Default).InstanceId | Should -Be $third.InstanceId
    }

    It 'honors WhatIf' {
        $first = Register-TestConnection work
        $first | Disconnect-AtlassianConnection -WhatIf

        $first.State | Should -Be 'Active'
    }

    It 'rejects temporary request contexts without changing the registered default' {
        $first = Register-TestConnection work
        $temporary = Resolve-AtlassianRequestContext -Product Jira -Connection $first -PersonalAccessToken other
        try {
            { Disconnect-AtlassianConnection -Connection $temporary } | Should -Throw
            (Get-AtlassianConnection -Product Jira -Default).InstanceId | Should -Be $first.InstanceId
            $first.State | Should -Be 'Active'
            $temporary.State | Should -Be 'Standalone'
        }
        finally { $temporary.Dispose() }
    }
}
