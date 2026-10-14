#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
Describe 'Assert-ConnectionActive' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
    }
    InModuleScope AtlassianPS.Configuration {
        It 'enforces the shared contract at its boundary' {

            $candidate = New-AtlassianConnectionContext -Name test -Product Jira -BaseUri https://jira.example.com -Anonymous
            { Assert-ConnectionActive -Connection $candidate } | Should -Throw
            $candidate.SetValidationResult('Server', $null)
            $active = Register-Connection -Connection $candidate
            { Assert-ConnectionActive -Connection $active -Product Jira } | Should -Not -Throw
            Disconnect-Connection -Connection $active
            { Assert-ConnectionActive -Connection $active } | Should -Throw

        }
    }
}
