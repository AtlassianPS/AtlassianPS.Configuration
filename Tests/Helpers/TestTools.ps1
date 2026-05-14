# Captured at dot-source time when $PSScriptRoot is this file's directory (Tests/Helpers/)
$script:_TestToolsDir = $PSScriptRoot

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

function Initialize-TestEnvironment {
    [CmdletBinding()]
    [OutputType([String])]
    param()

    $manifestPath = Resolve-ModuleSource
    $moduleDir = Split-Path $manifestPath -Parent

    # Detect source edits and rebuilds by tracking file write times under the
    # module directory currently under test.
    $fingerprint = (
        Get-ChildItem $moduleDir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in '.ps1', '.psm1', '.psd1', '.cs' } |
            ForEach-Object { $_.LastWriteTimeUtc.Ticks } |
            Measure-Object -Maximum
    ).Maximum

    $loaded = Get-Module AtlassianPS.Configuration
    if ($loaded -and $loaded.ModuleBase -eq $moduleDir) {
        $cached = & $loaded { $script:__TestImportFingerprint }
        if ($cached -eq $fingerprint) {
            return $manifestPath
        }
    }

    $projectRoot = Resolve-ProjectRoot
    $buildOutput = Join-Path $projectRoot 'Release'
    $projectName = 'AtlassianPS.Configuration'

    $env:BHProjectName = $projectName
    $env:BHProjectPath = $projectRoot
    $env:BHModulePath = Join-Path $projectRoot $projectName
    $env:BHPSModulePath = $env:BHModulePath
    $env:BHPSModuleManifest = Join-Path $env:BHModulePath "$projectName.psd1"
    $env:BHBuildOutput = $buildOutput
    $env:BHManifestToTest = $manifestPath
    $env:BHisBuild = $script:_TestToolsDir -match '[\\/]{1}Release[\\/]{1}'

    $buildToolsModule = Join-Path $projectRoot 'Tools/BuildTools.psm1'
    if (Test-Path $buildToolsModule) {
        Import-Module $buildToolsModule -Force
    }

    Get-Module |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'RequiredModules' -and
            @(
                foreach ($requiredModule in @($_.RequiredModules)) {
                    if ($requiredModule -is [String]) {
                        $requiredModule
                    }
                    elseif ($requiredModule.PSObject.Properties.Name -contains 'Name') {
                        $requiredModule.Name
                    }
                    elseif ($requiredModule.PSObject.Properties.Name -contains 'ModuleName') {
                        $requiredModule.ModuleName
                    }
                }
            ) -contains 'AtlassianPS.Configuration'
        } |
        Remove-Module -Force -ErrorAction SilentlyContinue
    Remove-Module AtlassianPS.Configuration -Force -ErrorAction SilentlyContinue

    Clear-TestConfigurationCache
    Import-Module $manifestPath -Force -ErrorAction Stop
    & (Get-Module AtlassianPS.Configuration) { param($fp) $script:__TestImportFingerprint = $fp } $fingerprint

    return $manifestPath
}

function Resolve-ModuleSource {
    [CmdletBinding()]
    [OutputType([String])]
    param()

    $projectRoot = Resolve-ProjectRoot
    ${/} = [System.IO.Path]::DirectorySeparatorChar

    $isBuild = $script:_TestToolsDir -match "[\\/]Release[\\/]"
    $moduleManifest = if ($isBuild) {
        Join-Path $projectRoot "Release${/}AtlassianPS.Configuration${/}AtlassianPS.Configuration.psd1"
    }
    else {
        Join-Path $projectRoot "AtlassianPS.Configuration${/}AtlassianPS.Configuration.psd1"
    }

    if (-not (Test-Path $moduleManifest)) {
        throw "Could not find AtlassianPS.Configuration module at: $moduleManifest"
    }

    return $moduleManifest
}

function Resolve-ProjectRoot {
    [CmdletBinding()]
    [OutputType([String])]
    param()

    $projectRoot = (Resolve-Path (Join-Path $script:_TestToolsDir '../..')).Path
    if ((Split-Path $projectRoot -Leaf) -eq 'Release') {
        $projectRoot = Split-Path $projectRoot -Parent
    }

    return $projectRoot
}

# Compatibility wrapper used by existing tests.
function Invoke-InitTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$Path
    )
    $null = $Path
    Initialize-TestEnvironment
}

# Compatibility wrapper used by existing tests.
function Invoke-TestCleanup {
    [CmdletBinding()]
    param()

    if ($env:BHProjectName) {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }
    Clear-TestConfigurationCache
}
