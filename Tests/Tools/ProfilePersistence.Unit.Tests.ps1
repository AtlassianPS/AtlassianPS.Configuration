#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'Profile persistence in a fresh process' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:manifest = Resolve-ModuleSource
        $script:engine = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    }

    It 'round trips apostrophes through actual Configuration metadata storage' {
        $runner = Join-Path $TestDrive 'profile-roundtrip.ps1'
        Set-Content $runner @'
param($Manifest, $Root)
$ErrorActionPreference = 'Stop'
$env:ATLASSIANPS_CONFIGURATION_ROOT = $Root
Import-Module $Manifest
$null = Add-AtlassianServerConfiguration -Name "O'Brien" -Uri https://jira.example.com -Type Jira
Remove-Module AtlassianPS.Configuration -Force
Import-Module $Manifest
$profile = Get-AtlassianServerConfiguration -Name "O'Brien"
if (-not $profile -or $profile.Name -cne "O'Brien" -or $profile.Uri.Host -ne 'jira.example.com') { exit 1 }
exit 0
'@
        & $script:engine -NoLogo -NonInteractive -NoProfile -File $runner $script:manifest (Join-Path $TestDrive 'profiles')

        $LASTEXITCODE | Should -Be 0
    }
}
