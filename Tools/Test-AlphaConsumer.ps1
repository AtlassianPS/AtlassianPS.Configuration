[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Justification = 'InvokeBuild exposes its documented Invoke-Build command as an alias.')]
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -eq 'Desktop') { Import-Module PowerShellGet -RequiredVersion 2.2.5 -Force }
$ledger = Get-Content .tmp/alpha-artifact/alpha-ledger.json -Raw | ConvertFrom-Json
$package = '.tmp/alpha-artifact/AtlassianPS.Configuration.zip'
$expectedCommit = if ($env:CONSUMER -eq 'jira') { $ledger.JiraSha }
else { $ledger.ConfigurationSha }
if ((Get-FileHash $package).Hash -ne $ledger.Sha256 -or $ledger.Version -cne $env:ALPHA_VERSION -or
    (git rev-parse HEAD) -ne $expectedCommit
) {
    throw 'Candidate artifact, version or commit mismatch.'
}
if ($env:CONSUMER -eq 'jira') {
    ./Tools/setup.ps1 -ConfigurationCandidatePackage $package -ConfigurationCandidateSha256 $ledger.Sha256 -ConfigurationCandidateRoot (Join-Path $PWD '.tmp/candidate-modules')
    Invoke-Build -Task Build, Test
    $result = Invoke-Pester -Path Tests/Help.Tests.ps1 -PassThru
    if ($result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount) { throw 'Jira help failed.' }
    Invoke-Build -Task Lint
}
else {
    ./Tools/setup.ps1
    Expand-Archive -LiteralPath $package -DestinationPath Release -Force
    Copy-Item Tests Release/Tests -Recurse
    Copy-Item PSScriptAnalyzerSettings.psd1 Release/PSScriptAnalyzerSettings.psd1
    Invoke-Build -Task Test
    Import-Module ./Release/AtlassianPS.Configuration/AtlassianPS.Configuration.psd1 -Force
    Get-Help about_AtlassianPS_Authentication -ErrorAction Stop | Out-Null
}
