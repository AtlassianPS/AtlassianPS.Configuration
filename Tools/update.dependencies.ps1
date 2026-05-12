#requires -Module PowerShellGet

[CmdletBinding()]
param()

$requirementsPath = Join-Path $PSScriptRoot 'build.requirements.psd1'

function Get-LatestModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    try {
        $latest = Find-Module -Name $ModuleName -Repository PSGallery -ErrorAction Stop
        return $latest.Version.ToString()
    }
    catch {
        Write-Warning "Unable to resolve latest version for module '$ModuleName'. Keeping existing version."
        Write-Warning $_
        return $null
    }
}

function Update-DependencyRequirements {
    [CmdletBinding()]
    param()

    if (-not (Test-Path -Path $requirementsPath)) {
        Write-Warning "Dependency file '$requirementsPath' not found."
        return
    }

    $requirements = Import-PowerShellDataFile -Path $requirementsPath
    if (-not ($requirements -is [array])) {
        Write-Warning "Expected array requirements in '$requirementsPath'."
        return
    }

    $outputLines = @('@(')
    foreach ($module in $requirements) {
        if (-not $module.ModuleName -or -not $module.RequiredVersion) {
            continue
        }

        Write-Output "Checking for module: $($module.ModuleName)"
        $newVersion = $module.RequiredVersion
        $latestVersion = Get-LatestModuleVersion -ModuleName $module.ModuleName
        if ($latestVersion -and ([version]$latestVersion -gt [version]$module.RequiredVersion)) {
            Write-Output "Updating $($module.ModuleName): v$($module.RequiredVersion) --> $latestVersion"
            $newVersion = $latestVersion
        }

        $outputLines += "    @{ ModuleName = `"$($module.ModuleName)`"; RequiredVersion = `"$newVersion`" }"
    }
    $outputLines += ')'

    $fileContent = ($outputLines -join "`r`n") + "`r`n"
    [System.IO.File]::WriteAllText($requirementsPath, $fileContent, [System.Text.UTF8Encoding]::new($false))
}

Update-DependencyRequirements
