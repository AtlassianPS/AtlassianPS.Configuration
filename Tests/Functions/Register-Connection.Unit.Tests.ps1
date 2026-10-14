#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
Describe 'Register-Connection' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        function Register-TestConnection {
            param([String]$Name, [String]$Product = 'Jira', [Switch]$Default)
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

    It 'selects only the first success unless Default is requested' {
        $first = Register-TestConnection work
        $second = Register-TestConnection admin
        (Get-AtlassianConnection -Product Jira -Default).InstanceId | Should -Be $first.InstanceId
        $third = Register-TestConnection third -Default
        (Get-AtlassianConnection -Product Jira -Default).InstanceId | Should -Be $third.InstanceId
        $second.BaseUri | Should -Be $first.BaseUri
    }
    It 'rejects duplicate names without changing the existing default' {
        $first = Register-TestConnection work
        { Register-TestConnection WORK -Default } | Should -Throw
        (Get-AtlassianConnection -Product Jira -Default).InstanceId | Should -Be $first.InstanceId
    }
    It 'requires successful validation before registration' {
        $candidate = New-AtlassianConnectionContext -Name work -Product Jira -BaseUri https://jira.example.com -Anonymous
        { Register-AtlassianConnection -Connection $candidate } | Should -Throw
        @(Get-AtlassianConnection).Count | Should -Be 0
        $candidate.Dispose()
    }

}
