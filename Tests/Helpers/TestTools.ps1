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

function Initialize-TestBuildEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter(Mandatory)]
        [string]$ProjectRoot
    )

    $modulePath = Join-Path $ProjectRoot $ModuleName

    $env:BHProjectName = $ModuleName
    $env:BHProjectPath = $ProjectRoot
    $env:BHModulePath = $modulePath
    $env:BHPSModulePath = $modulePath
    $env:BHPSModuleManifest = Join-Path $modulePath "$ModuleName.psd1"
    $env:BHBuildOutput = Join-Path $ProjectRoot 'Release'
    $env:BHManifestToTest = $ManifestPath
    $env:BHisBuild = if ($script:_TestToolsDir -match '[\\/]{1}Release[\\/]{1}') { 'True' } else { '' }
}

function Initialize-TestEnvironment {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $moduleName = 'AtlassianPS.Configuration'
    $manifestPath = Resolve-ModuleSource
    $moduleDir = Split-Path $manifestPath -Parent
    $projectRoot = Resolve-ProjectRoot

    # Keep BH* context stable on every call, including cache-hit fast paths.
    Initialize-TestBuildEnvironment -ModuleName $moduleName -ManifestPath $manifestPath -ProjectRoot $projectRoot

    # Cheapest robust freshness signal: max LastWriteTimeUtc across all module
    # files under the module directory.
    $fingerprint = (
        Get-ChildItem $moduleDir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in '.ps1', '.psm1', '.psd1', '.cs' } |
            ForEach-Object { $_.LastWriteTimeUtc.Ticks } |
            Measure-Object -Maximum
    ).Maximum

    # Get-Module exposes the .psm1 as .Path (not the .psd1 manifest), so the
    # stable identity for "same module loaded" is .ModuleBase, the directory
    # containing the manifest.
    $loaded = Get-Module $moduleName |
        Where-Object { $_.ModuleBase -eq $moduleDir } |
        Select-Object -First 1
    if ($loaded) {
        $cached = & $loaded { $script:__TestImportFingerprint }
        if ($cached -eq $fingerprint) {
            return $manifestPath
        }
    }

    Get-Module |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'RequiredModules' -and
            @(
                foreach ($requiredModule in @($_.RequiredModules)) {
                    if ($requiredModule -is [string]) {
                        $requiredModule
                    }
                    elseif ($requiredModule.PSObject.Properties.Name -contains 'Name') {
                        $requiredModule.Name
                    }
                    elseif ($requiredModule.PSObject.Properties.Name -contains 'ModuleName') {
                        $requiredModule.ModuleName
                    }
                }
            ) -contains $moduleName
        } |
        Remove-Module -Force -ErrorAction SilentlyContinue
    Remove-Module $moduleName -Force -ErrorAction SilentlyContinue

    Clear-TestConfigurationCache
    Import-Module $manifestPath -Force -ErrorAction Stop

    $loaded = Get-Module $moduleName |
        Where-Object { $_.ModuleBase -eq $moduleDir } |
        Select-Object -First 1
    if (-not $loaded) {
        throw "Failed to load module from manifest: $manifestPath"
    }

    & $loaded { param($fp) $script:__TestImportFingerprint = $fp } $fingerprint

    return $manifestPath
}

function Resolve-ModuleSource {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $moduleName = 'AtlassianPS.Configuration'
    $projectRoot = Resolve-ProjectRoot
    ${/} = [System.IO.Path]::DirectorySeparatorChar

    if ($PSScriptRoot -like "*${/}Release${/}*") {
        $projectRoot = (Resolve-Path "$projectRoot/Release").Path
    }

    $moduleManifest = Join-Path $projectRoot "$moduleName${/}$moduleName.psd1"

    if (-not (Test-Path $moduleManifest)) {
        throw "Could not find $moduleName module at: $moduleManifest"
    }

    Write-Verbose "Using module at: $moduleManifest"
    return $moduleManifest
}

function Resolve-ProjectRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $candidate = (Resolve-Path $script:_TestToolsDir).Path
    while ($candidate -and ($candidate -ne [System.IO.Path]::GetPathRoot($candidate))) {
        if (Test-Path (Join-Path $candidate 'CODEOWNERS')) {
            return $candidate
        }
        if (Test-Path (Join-Path $candidate '.github/CODEOWNERS')) {
            return $candidate
        }
        $candidate = Split-Path $candidate -Parent
    }

    throw "Could not find project root (no CODEOWNERS marker found in any parent of $($script:_TestToolsDir))"
}

function Write-MockDebugInfo {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Mandatory)]
        [string]$FunctionName,

        [Parameter()]
        [string[]]$Params
    )

    if ($VerbosePreference -eq 'SilentlyContinue') { return }

    Write-Host "     🔷 Mock: $FunctionName" -ForegroundColor Cyan

    if ($Params) {
        foreach ($paramName in $Params) {
            $value = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue

            if ($null -eq $value) {
                Write-Host "         [$paramName] = <null>" -ForegroundColor DarkGray
            }
            elseif ($value -is [string] -and [string]::IsNullOrEmpty($value)) {
                Write-Host "         [$paramName] = <empty string>" -ForegroundColor DarkGray
            }
            elseif ($value -is [array]) {
                Write-Host "         [$paramName] = @(" -ForegroundColor Yellow -NoNewline
                Write-Host "$($value.Count) items" -ForegroundColor Magenta -NoNewline
                Write-Host ")" -ForegroundColor Yellow
                if ($value.Count -le 5) {
                    foreach ($item in $value) {
                        Write-Host "           - $item" -ForegroundColor DarkYellow
                    }
                }
            }
            elseif ($value -is [hashtable] -or $value -is [System.Collections.IDictionary]) {
                Write-Host "         [$paramName] = @{" -ForegroundColor Yellow -NoNewline
                Write-Host "$($value.Count) keys" -ForegroundColor Magenta -NoNewline
                Write-Host "}" -ForegroundColor Yellow
            }
            else {
                $displayValue = if ($value.ToString().Length -gt 100) {
                    "$($value.ToString().Substring(0, 97))..."
                }
                else {
                    $value.ToString()
                }
                Write-Host "         [$paramName] = $displayValue" -ForegroundColor Yellow
            }
        }
    }
}

function Get-FileEncoding {
    [CmdletBinding()]
    [OutputType('EncodingInfo')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [Alias('FullName')]
        [string]$Path,

        [switch]$IncludeBinary
    )

    begin {
        $signatures = [ordered]@{
            'UTF32-LE'   = 'FF-FE-00-00'
            'UTF32be'    = '00-00-FE-FF'
            'UTF8-BOM'   = 'EF-BB-BF'
            'UTF16-LE'   = 'FF-FE'
            'UTF16be'    = 'FE-FF'
            'UTF7'       = '2B-2F-76-38', '2B-2F-76-39', '2B-2F-76-2B', '2B-2F-76-2F'
            'UTF1'       = 'F7-64-4C'
            'UTF-EBCDIC' = 'DD-73-66-73'
            'SCSU'       = '0E-FE-FF'
            'BOCU-1'     = 'FB-EE-28'
            'GB-18030'   = '84-31-95-33'
        }

        if ($IncludeBinary) {
            $signatures += [ordered]@{
                'LNK'      = '4C-00-00-00-01-14-02-00'
                'MSEXCEL'  = '50-4B-03-04-14-00-06-00'
                'PNG'      = '89-50-4E-47-0D-0A-1A-0A'
                'MSOFFICE' = 'D0-CF-11-E0-A1-B1-1A-E1'
                '7ZIP'     = '37-7A-BC-AF-27-1C'
                'RTF'      = '7B-5C-72-74-66-31'
                'GIF'      = '47-49-46-38'
                'REGPOL'   = '50-52-65-67'
                'JPEG'     = 'FF-D8'
                'MSEXE'    = '4D-5A'
                'ZIP'      = '50-4B'
            }
        }

        [string[]]$keys = $signatures.Keys
        foreach ($name in $keys) {
            [System.Collections.Generic.List[System.Collections.Generic.List[byte]]]$values = foreach ($value in $signatures[$name]) {
                [System.Collections.Generic.List[byte]]$signatureBytes = foreach ($byte in $value.Split('-')) {
                    [Convert]::ToByte($byte, 16)
                }
                , $signatureBytes
            }
            $signatures[$name] = $values
        }
    }

    process {
        try {
            $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path)

            $bytes = [byte[]]::new(8)
            $stream = [System.IO.StreamReader]::new($Path)
            $null = $stream.Peek()
            $enc = $stream.CurrentEncoding
            $stream.Close()
            $stream = [System.IO.File]::OpenRead($Path)
            $null = $stream.Read($bytes, 0, $bytes.Count)
            $bytes = [System.Collections.Generic.List[byte]]$bytes
            $stream.Close()

            if ($enc -eq [System.Text.Encoding]::UTF8) {
                $encoding = 'UTF8'
            }

            foreach ($name in $signatures.Keys) {
                $sampleEncoding = foreach ($sequence in $signatures[$name]) {
                    $sample = $bytes.GetRange(0, $sequence.Count)

                    if ([System.Linq.Enumerable]::SequenceEqual($sample, $sequence)) {
                        $name
                        break
                    }
                }
                if ($sampleEncoding) {
                    $encoding = $sampleEncoding
                    break
                }
            }

            if (-not $encoding) {
                $encoding = 'ASCII'
            }

            [PSCustomObject]@{
                Name      = Split-Path $Path -Leaf
                Extension = [System.IO.Path]::GetExtension($Path)
                Encoding  = $encoding
                Path      = $Path
            } | Add-Member -TypeName 'EncodingInfo' -PassThru
        }
        catch {
            $pscmdlet.WriteError($_)
        }
    }
}

function global:LogCall {
    if (-not (Test-Path TestDrive:\)) {
        throw "This function only works inside pester"
    }

    Set-Content -Value "$($MyInvocation.InvocationName) $($MyInvocation.UnBoundArguments -join ' ')" -Path "TestDrive:\FunctionCalled.$($MyInvocation.InvocationName).txt" -Force
}

# Compatibility wrapper used by existing tests.
function Invoke-InitTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
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
    if (Get-Alias -Name Import-Configuration -ErrorAction SilentlyContinue) {
        $importConfigurationAlias = Get-Alias -Name Import-Configuration -ErrorAction SilentlyContinue
        if ($importConfigurationAlias -and $importConfigurationAlias.Definition -eq 'LogCall') {
            Remove-Item -Path Alias:\Import-Configuration -ErrorAction SilentlyContinue
        }
    }
    Clear-TestConfigurationCache
}
