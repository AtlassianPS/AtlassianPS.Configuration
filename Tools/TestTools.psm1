#region ExposedFunctions
function Clear-TestConfigurationCache {
    [CmdletBinding()]
    param()

    $configurationPaths = @(
        Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'powershell/AtlassianPS/AtlassianPS.Configuration/Configuration.psd1'
        Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'powershell/AtlassianPS/AtlassianPS.Configuration/Configuration.psd1'
        Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'powershell/AtlassianPS/AtlassianPS.Configuration/Configuration.psd1'
        Join-Path $HOME '.config/powershell/AtlassianPS/AtlassianPS.Configuration/Configuration.psd1'
        Join-Path $HOME '.local/share/powershell/AtlassianPS/AtlassianPS.Configuration/Configuration.psd1'
    ) | Select-Object -Unique

    foreach ($path in $configurationPaths) {
        if ($path -and (Test-Path $path)) {
            Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        }
    }
}

function Invoke-InitTest {
    param(
        [Parameter(Mandatory)]
        $Path
    )

    Remove-Item -Path Env:\BH*
    $projectRoot = (Resolve-Path "$Path/../..").Path
    if ($projectRoot -like "*Release") {
        $projectRoot = (Resolve-Path "$projectRoot/..").Path
    }

    $projectName = Split-Path -Path $projectRoot -Leaf
    $env:BHProjectName = $projectName
    $env:BHProjectPath = $projectRoot
    $env:BHModulePath = Join-Path $projectRoot $projectName
    $env:BHPSModulePath = $env:BHModulePath
    $env:BHPSModuleManifest = Join-Path $env:BHModulePath "$projectName.psd1"
    $env:BHBuildOutput = Join-Path $projectRoot 'Release'

    $env:BHManifestToTest = $env:BHPSModuleManifest
    $env:BHisBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
    if ($env:BHisBuild) {
        $Pattern = [regex]::Escape($env:BHProjectPath)

        $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
        $env:BHManifestToTest = $env:BHBuildModuleManifest
    }

    Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"
    if ($env:BHProjectName) {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }

    Clear-TestConfigurationCache
}

function Invoke-TestCleanup {
    param()
    if ($env:BHProjectName) {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }
    Clear-TestConfigurationCache
    Remove-Item -Path Env:\BH*
}
#endregion ExposedFunctions
