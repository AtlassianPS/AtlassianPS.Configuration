[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingCmdletAliases',
    '',
    Justification = 'InvokeBuild exposes its documented Invoke-Build command as an alias.'
)]
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Import-Module PowerShellGet -RequiredVersion 2.2.5 -Force
$ledger = Get-Content .tmp/alpha-artifact/published-ledger.json -Raw | ConvertFrom-Json
if ($ledger.Version -cne $env:ALPHA_VERSION -or (git rev-parse HEAD) -ne $ledger.JiraSha) {
    throw 'Gallery consumer version or source mismatch.'
}
$moduleRoot = Join-Path $PWD '.tmp/gallery-modules'
$null = New-Item -Path $moduleRoot -ItemType Directory
Save-Module -Name AtlassianPS.Configuration -RequiredVersion $env:ALPHA_VERSION -AllowPrerelease -Repository PSGallery -Path $moduleRoot -ErrorAction Stop
$package = Join-Path $PWD '.tmp/gallery-package.nupkg'
Invoke-WebRequest -Uri ("https://www.powershellgallery.com/api/v2/package/AtlassianPS.Configuration/" + $env:ALPHA_VERSION) -OutFile $package -ErrorAction Stop
if ((Get-FileHash $package).Hash -ne $ledger.GallerySha256) { throw 'Gallery package hash changed.' }
$manifest = @(Get-ChildItem "$moduleRoot/AtlassianPS.Configuration" -Recurse -Filter AtlassianPS.Configuration.psd1)
if ($manifest.Count -ne 1) { throw 'Expected exactly one acquired Configuration manifest.' }
$data = Import-PowerShellDataFile $manifest[0].FullName
if (($data.ModuleVersion + '-' + $data.PrivateData.PSData.Prerelease) -cne $env:ALPHA_VERSION) {
    throw 'The acquired Gallery module has a different version or prerelease label.'
}
$env:PSModulePath = $moduleRoot + [IO.Path]::PathSeparator + $env:PSModulePath
$env:ATLASSIANPS_CONFIGURATION_ROOT = Join-Path $moduleRoot '.configuration'
Import-Module $manifest[0].FullName -Global
./Tools/setup.ps1
Invoke-Build -Task Build, Test
$result = Invoke-Pester -Path Tests/Help.Tests.ps1 -PassThru
if ($result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount) { throw 'Gallery consumer help failed.' }
