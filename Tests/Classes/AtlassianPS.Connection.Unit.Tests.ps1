#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
Describe 'AtlassianPS.Connection' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
    }

    It 'freezes registered metadata and invalidates on runtime unload' {
        $candidate = New-AtlassianConnectionContext -Name test -Product Jira -BaseUri https://jira.example.com -Anonymous
        $candidate.SetValidationResult('Server', $null)
        $active = Register-AtlassianConnection -Connection $candidate

        { $active.BaseUri = [Uri]'https://another.example.com' } | Should -Throw
        { $active.SetValidationResult('Cloud', 'another') } | Should -Throw
        $temporary = Resolve-AtlassianRequestContext -Product Jira -Connection $active -PersonalAccessToken temporary
        Remove-Module AtlassianPS.Configuration -Force

        $active.State | Should -Be Disconnected
        $temporary.State | Should -Be Disconnected
        Import-Module $moduleToTest

        { Resolve-AtlassianRequestContext -Product Jira -Connection $active } | Should -Throw
    }
}
