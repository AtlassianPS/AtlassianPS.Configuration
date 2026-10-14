#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
Describe 'Export-ServerConfiguration' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
    }
    It 'writes only approved profile fields and omits a legacy session' {
        Mock Get-ServerConfiguration -ModuleName AtlassianPS.Configuration {
            [AtlassianPS.ServerData]@{ Id = 1; Name = 'test'; Uri = 'https://jira.example.com'; Type = 'Jira'; Session = 'secret-sentinel' }
        }
        $path = Join-Path $TestDrive 'profiles.json'
        Export-AtlassianServerConfiguration -Path $path
        $source = Get-Content -LiteralPath $path -Raw
        $source | Should -Not -Match 'secret-sentinel|Session|Headers|Certificate'
        ($source | ConvertFrom-Json).SchemaVersion | Should -Be 1
    }
    It 'rejects arbitrary legacy headers before creating a file' {
        Mock Get-ServerConfiguration -ModuleName AtlassianPS.Configuration {
            [AtlassianPS.ServerData]@{ Id = 1; Name = 'test'; Uri = 'https://jira.example.com'; Type = 'Jira'; Headers = @{ Authorization = 'secret-sentinel' } }
        }
        $path = Join-Path $TestDrive 'forbidden.json'
        { Export-AtlassianServerConfiguration -Path $path } | Should -Throw
        Test-Path $path | Should -BeFalse
    }
}
