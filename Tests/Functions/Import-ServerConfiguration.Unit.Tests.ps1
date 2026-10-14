#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
Describe 'Import-ServerConfiguration' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
    }

    BeforeEach {
        Mock Save-Configuration {} -ModuleName AtlassianPS.Configuration
        & (Get-Module AtlassianPS.Configuration) {
            $script:Configuration['ServerList'] = [Collections.Generic.List[AtlassianPS.ServerData]]::new()
        }
    }

    It 'imports a versioned profile and rejects duplicate replacement without mutation' {
        $path = Join-Path $TestDrive 'profiles.json'
        Set-Content -LiteralPath $path -Value '{"SchemaVersion":1,"ServerList":[{"Id":1,"Name":"work","Uri":"https://jira.example.com","Type":"Jira"}]}'
        Import-AtlassianServerConfiguration -Path $path

        (Get-AtlassianServerConfiguration -Name work).Uri.Host | Should -Be jira.example.com
        { Import-AtlassianServerConfiguration -Path $path } | Should -Throw
        @(Get-AtlassianServerConfiguration).Count | Should -Be 1
        Should -Invoke Save-Configuration -ModuleName AtlassianPS.Configuration -Times 1 -Exactly
    }

    It 'rejects unsupported fields atomically' {
        $path = Join-Path $TestDrive 'profiles.json'
        Set-Content -LiteralPath $path -Value '{"SchemaVersion":1,"ServerList":[{"Id":1,"Name":"work","Uri":"https://jira.example.com","Type":"Jira"},{"Name":"bad","Uri":"https://jira.example.com","Type":"Jira","Token":"secret"}]}'

        { Import-AtlassianServerConfiguration -Path $path } | Should -Throw
        @(Get-AtlassianServerConfiguration).Count | Should -Be 0
        Should -Invoke Save-Configuration -ModuleName AtlassianPS.Configuration -Times 0 -Exactly
    }

    It 'restores the previous in-memory profile list when persistence fails' {
        $existing = [AtlassianPS.ServerData]@{
            Id   = 1
            Name = 'original'
            Uri  = 'https://original.example.com'
            Type = 'Jira'
        }
        & (Get-Module AtlassianPS.Configuration) {
            param($value)

            $script:Configuration['ServerList'].Add($value)
        } $existing
        Mock Save-Configuration { throw 'Simulated disk write failure.' } -ModuleName AtlassianPS.Configuration
        $path = Join-Path $TestDrive 'profiles.json'
        Set-Content -LiteralPath $path -Value '{"SchemaVersion":1,"ServerList":[{"Id":2,"Name":"new","Uri":"https://jira.example.com","Type":"Jira"}]}'

        { Import-AtlassianServerConfiguration -Path $path } | Should -Throw '*disk write failure*'
        @(Get-AtlassianServerConfiguration).Count | Should -Be 1
        (Get-AtlassianServerConfiguration).Name | Should -Be original
    }

}
