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

    It 'saves nonsecret profile projections without changing live compatibility fields' {
        $runner = Join-Path $TestDrive 'profile-projection.ps1'
        Set-Content $runner @'
param($Manifest, $Root)
$ErrorActionPreference = 'Stop'
$env:ATLASSIANPS_CONFIGURATION_ROOT = $Root
Import-Module $Manifest
Add-AtlassianServerConfiguration -Name legacy -Uri https://jira.example.com/jira -Type Jira -Headers @{ Authorization = 'header-sentinel' } -WarningAction SilentlyContinue
Add-AtlassianServerConfiguration -Name other -Uri https://other.example.com -Type Jira
Set-AtlassianServerConfiguration -Id (Get-AtlassianServerConfiguration -Name legacy).Id -Headers @{ Authorization = 'updated-header-sentinel' } -WarningAction SilentlyContinue
$legacy = Get-AtlassianServerConfiguration -Name legacy
$legacy.Uri = [Uri]'https://profile-user:password-sentinel@jira.example.com/jira?token=query-sentinel#fragment'
$legacy.Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]::new()
$legacy.Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
Set-AtlassianConfiguration -Name Message -Value (Get-AtlassianConfiguration -Name Message -ValueOnly)
if ($legacy.Headers.Authorization -ne 'updated-header-sentinel' -or $legacy.Uri.UserInfo -notmatch 'password-sentinel' -or -not $legacy.Certificate -or -not $legacy.Session) { throw 'Live compatibility fields were changed.' }
$saved = (Get-ChildItem -LiteralPath $Root -File -Recurse | Get-Content -Raw) -join ''
if ($saved -match 'header-sentinel|password-sentinel|query-sentinel') { throw 'Secret fields were persisted.' }
$before = @(Get-AtlassianServerConfiguration).Count
try {
    Add-AtlassianServerConfiguration -Name invalid -Uri 'https://jira.example.com?token=value' -Type Jira
    throw 'Invalid endpoint was accepted.'
}
catch [System.Management.Automation.ParameterBindingException] { }
if (@(Get-AtlassianServerConfiguration).Count -ne $before) { throw 'Rejected profile changed live state.' }
try {
    Set-AtlassianServerConfiguration -Id $legacy.Id -Uri 'https://jira.example.com#fragment'
    throw 'Invalid endpoint update was accepted.'
}
catch [System.Management.Automation.ParameterBindingException] { }
Remove-Module AtlassianPS.Configuration -Force
Import-Module $Manifest
$stored = Get-AtlassianServerConfiguration -Name legacy
if ($stored.Uri.AbsoluteUri -ne 'https://jira.example.com/jira' -or $stored.Headers.Count -or $stored.Certificate -or $stored.Session) { throw 'Stored profile did not contain only endpoint settings.' }
if (@(Get-AtlassianServerConfiguration).Count -ne $before) { throw 'Valid profiles were lost.' }
'@
        & $script:engine -NoLogo -NonInteractive -NoProfile -File $runner $script:manifest (Join-Path $TestDrive 'profile-projection')

        $LASTEXITCODE | Should -Be 0
    }
}
