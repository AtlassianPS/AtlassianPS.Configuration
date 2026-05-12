#requires -Module PowerShellGet

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
param()

$psScriptAnalyzerSettingsPath = Join-Path (Join-Path $PSScriptRoot '..') 'PSScriptAnalyzerSettings.psd1'
function Sync-PSScriptAnalyzerSetting {
    [CmdletBinding()]
    param()

    Write-Host "Syncing PSScriptAnalyzer settings from AtlassianPS.Standards"

    try {
        Import-Module AtlassianPS.Standards -RequiredVersion '0.1.0' -ErrorAction Stop
        $sourceSettingsPath = Get-AtlassianPSScriptAnalyzerSettingsPath

        if (-not (Test-Path -Path $sourceSettingsPath -PathType Leaf)) {
            throw "Resolved shared settings path '$sourceSettingsPath' does not exist."
        }

        # Generate a local shim in repo root so existing build/test/lint flows stay unchanged.
        Copy-Item -Path $sourceSettingsPath -Destination $psScriptAnalyzerSettingsPath -Force
        Write-Host "PSScriptAnalyzer settings synchronized to '$psScriptAnalyzerSettingsPath'."
    }
    catch {
        throw "Unable to synchronize PSScriptAnalyzer settings from AtlassianPS.Standards. $($_.Exception.Message)"
    }
}

# PowerShell 5.1 and bellow need the PSGallery to be intialized
if (-not ($gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PackageProvider NuGet"
    $null = Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
}

# Update PowerShellGet if needed
if ((Get-Module PowershellGet -ListAvailable)[0].Version -lt [version]"1.6.0") {
    Write-Host "Updating PowershellGet"
    Install-Module PowershellGet -Scope CurrentUser -Force
}

Write-Host "Installing Dependencies"
Import-Module "$PSScriptRoot/BuildTools.psm1" -Force
Install-Dependency

Sync-PSScriptAnalyzerSetting
