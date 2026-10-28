#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'Get-Connection' -Tag Unit {
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

    It 'filters products and keeps independent defaults' {
        $jira = Register-TestConnection work
        $other = Register-TestConnection work -Product TestProduct

        @(Get-AtlassianConnection).Count | Should -Be 2
        (Get-AtlassianConnection -Product Jira -Name WORK).InstanceId | Should -Be $jira.InstanceId
        (Get-AtlassianConnection -Id $other.Id).Product | Should -Be 'TestProduct'
        @(Get-AtlassianConnection -Default).Count | Should -Be 2
    }

    It 'does not export double-prefixed names' {
        Get-Command -Name Get-AtlassianConnection -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command -Name Get-AtlassianAtlassianConnection -ErrorAction Ignore | Should -BeNullOrEmpty
    }

    It 'excludes disposed connections without clearing another product default' {
        $jira = Register-TestConnection work
        $other = Register-TestConnection work -Product TestProduct
        $jira.Dispose()

        @(Get-AtlassianConnection).Count | Should -Be 1
        Get-AtlassianConnection -Product Jira -Default | Should -BeNullOrEmpty
        (Get-AtlassianConnection -Product TestProduct -Default).InstanceId | Should -Be $other.InstanceId
    }
}
