#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'Resolve-RequestContext' -Tag Unit {
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

    It 'isolates overrides and preserves the stored identity' {
        $connection = Register-TestConnection work
        $override = Resolve-AtlassianRequestContext -Product Jira -Connection $connection -PersonalAccessToken alternate

        $override.InstanceId | Should -Not -Be $connection.InstanceId
        $override.SourceInstanceId | Should -Be $connection.InstanceId
        $override.GetAuthorizationHeader() | Should -Be 'Bearer alternate'
        $connection.GetAuthorizationHeader() | Should -Be 'Bearer original'
        $override.Dispose()

        $connection.State | Should -Be 'Active'
    }

    It 'rejects wrong products, deserialized objects and explicit empty overrides' {
        $connection = Register-TestConnection work

        { Resolve-AtlassianRequestContext -Product TestProduct -Connection $connection } | Should -Throw
        { Resolve-AtlassianRequestContext -Product Jira -Connection $connection -PersonalAccessToken '' } | Should -Throw
        { Resolve-AtlassianRequestContext -Product Jira -Connection $connection -ConnectionName work } | Should -Throw
        $deserialized = [Management.Automation.PSSerializer]::Deserialize([Management.Automation.PSSerializer]::Serialize($connection))

        { Resolve-AtlassianRequestContext -Product Jira -Connection $deserialized } | Should -Throw
    }

    It 'does not register standalone contexts or borrow the default identity' {
        $connection = Register-TestConnection work
        $standalone = Resolve-AtlassianRequestContext -Product Jira -BaseUri https://another.example.com -Anonymous

        $standalone.GetAuthorizationHeader() | Should -BeNullOrEmpty
        @(Get-AtlassianConnection).Count | Should -Be 1
        (Get-AtlassianConnection -Default).InstanceId | Should -Be $connection.InstanceId
        $standalone.Dispose()
    }
}
