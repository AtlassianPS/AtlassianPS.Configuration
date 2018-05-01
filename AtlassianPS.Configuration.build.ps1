#Requires -Modules Pester
#Requires -Modules PSScriptAnalyzer

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingEmptyCatchBlock', '')]
param(
    $ModuleName = (Split-Path $BuildRoot -Leaf),
    $releasePath = "$BuildRoot\Release"
)

#region Setup
$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
    $DebugPreference = "Continue"
}

try {
    $script:IsWindows = (-not (Get-Variable -Name IsWindows -ErrorAction Ignore)) -or $IsWindows
    $script:IsLinux = (Get-Variable -Name IsLinux -ErrorAction Ignore) -and $IsLinux
    $script:IsMacOS = (Get-Variable -Name IsMacOS -ErrorAction Ignore) -and $IsMacOS
    $script:IsCoreCLR = $PSVersionTable.ContainsKey('PSEdition') -and $PSVersionTable.PSEdition -eq 'Core'
}
catch { }

$PSModulePath = $env:PSModulePath -split ([IO.Path]::PathSeparator)
if ($releasePath -notin $PSModulePath) {
    $PSModulePath += $releasePath
    $env:PSModulePath = $PSModulePath -join ([IO.Path]::PathSeparator)
}

Set-StrictMode -Version Latest
#endregion Setup

#region BuildRelease
# Synopsis: Build shippable release
task Build GenerateRelease, UpdateManifest

# Synopsis: Generate .\Release structure
task GenerateRelease {
    # Setup
    if (-not (Test-Path "$releasePath/$ModuleName")) {
        $null = New-Item -Path "$releasePath/$ModuleName" -ItemType Directory
    }

    # Copy module
    Copy-Item -Path "$BuildRoot/$ModuleName/*" -Destination "$releasePath/$ModuleName" -Recurse -Force
    # Copy additional files
    Copy-Item -Path @(
        "$BuildRoot/CHANGELOG.md"
        "$BuildRoot/LICENSE"
        "$BuildRoot/README.md"
    ) -Destination "$releasePath/$ModuleName" -Force
    # Copy Tests
    $null = New-Item -Path "$releasePath/Tests" -ItemType Directory -ErrorAction SilentlyContinue
    Copy-Item -Path "$BuildRoot/Tests/*.ps1" -Destination "$releasePath/Tests" -Recurse -Force
    # Include Analyzer Settings
    Copy-Item -Path "$BuildRoot/PSScriptAnalyzerSettings.psd1" -Destination "$releasePath/PSScriptAnalyzerSettings.psd1" -Force
    Update-MetaData -Path "$releasePath/PSScriptAnalyzerSettings.psd1" -PropertyName ExcludeRules -Value ''

}, CompileModule

# Synopsis: Compile all functions into the .psm1 file
task CompileModule {
    $regionsToKeep = @('Dependencies', 'ModuleConfig')

    $targetFile = "$releasePath/$ModuleName/$ModuleName.psm1"
    $content = Get-Content -Encoding UTF8 -LiteralPath $targetFile
    $capture = $false
    $compiled = ""

    foreach ($line in $content) {
        if ($line -match "^#region ($($regionsToKeep -join "|"))$") {
            $capture = $true
        }
        if (($capture -eq $true) -and ($line -match "^#endregion")) {
            $capture = $false
        }

        if ($capture) {
            $compiled += "$line`n"
        }
    }

    $PublicFunctions = @( Get-ChildItem -Path "$releasePath/$ModuleName/Public/*.ps1" -ErrorAction SilentlyContinue )
    $PrivateFunctions = @( Get-ChildItem -Path "$releasePath/$ModuleName/Private/*.ps1" -ErrorAction SilentlyContinue )

    foreach ($function in @($PublicFunctions + $PrivateFunctions)) {
        $compiled += (Get-Content -Path $function.FullName -Raw)
        $compiled += "`n"
    }

    Set-Content -LiteralPath $targetFile -Value $compiled -Encoding UTF8 -Force
    "Private", "Public" | Foreach-Object { Remove-Item -Path "$releasePath/$ModuleName/$_" -Recurse -Force }
}

# Synopsis: Update the manifest of the module
task UpdateManifest GetVersion, {
    Remove-Module $ModuleName -ErrorAction SilentlyContinue
    Import-Module "$BuildRoot/$ModuleName/$ModuleName.psd1" -Force
    $ModuleAlias = @(Get-Alias | Where-Object {$_.ModuleName -eq "$ModuleName"})

    Remove-Module $ModuleName -ErrorAction SilentlyContinue
    Import-Module $ModuleName -Force

    Remove-Module BuildHelpers -ErrorAction SilentlyContinue
    Import-Module BuildHelpers -Force

    BuildHelpers\Update-Metadata -Path "$releasePath/$ModuleName/$ModuleName.psd1" -PropertyName ModuleVersion -Value $script:Version
    BuildHelpers\Update-Metadata -Path "$releasePath/$ModuleName/$ModuleName.psd1" -PropertyName FileList -Value (Get-ChildItem "$releasePath/$ModuleName" -Recurse).Name
    if ($ModuleAlias) {
        BuildHelpers\Update-Metadata -Path "$releasePath/$ModuleName/$ModuleName.psd1" -PropertyName AliasesToExport -Value @($ModuleAlias.Name)
    }
    else {
        BuildHelpers\Update-Metadata -Path "$releasePath/$ModuleName/$ModuleName.psd1" -PropertyName AliasesToExport -Value ''
    }
    BuildHelpers\Set-ModuleFunctions -Name "$releasePath/$ModuleName/$ModuleName.psd1" -FunctionsToExport ([string[]](Get-ChildItem "$BuildRoot\$ModuleName\Public\*.ps1").BaseName)
}

task GetVersion {
    $BUILD_NUMBER = if ($env:APPVEYOR_BUILD_NUMBER) {$env:APPVEYOR_BUILD_NUMBER} elseif ($env:TRAVIS_BUILD_NUMBER) {$env:TRAVIS_BUILD_NUMBER} else {''}

    $manifestContent = Get-Content -Path "$releasePath/$ModuleName/$ModuleName.psd1" -Raw
    if ($manifestContent -notmatch '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')') {
        throw "Module version was not found in manifest file."
    }

    $currentVersion = [Version]($Matches.ModuleVersion)
    if ($BUILD_NUMBER) {
        $newRevision = $BUILD_NUMBER
    }
    else {
        $newRevision = 0
    }
    $script:Version = New-Object -TypeName System.Version -ArgumentList $currentVersion.Major,
    $currentVersion.Minor,
    $newRevision
}
#endregion BuildRelease

#region Test
# Synopsis: Run Pester tests on the module
task Test Build, {
    assert { Test-Path "$BuildRoot/Release/Tests/" -PathType Container }

    Remove-Module BuildHelpers -ErrorAction SilentlyContinue
    Import-Module BuildHelpers -Force

    try {
        $result = Invoke-Pester -Script "$BuildRoot/Release/Tests/*" -PassThru -OutputFile "$BuildRoot/TestResult.xml" -OutputFormat "NUnitXml"
        if ($env:APPVEYOR_JOB_ID) {
            BuildHelpers\Add-TestResultToAppveyor -TestFile "$BuildRoot/TestResult.xml"
        }
        Remove-Item "$BuildRoot/TestResult.xml" -Force
        assert ($result.FailedCount -eq 0) "$($result.FailedCount) Pester test(s) failed."
    }
    catch {
        throw $_
    }
}
#endregion

#region Publish
$shouldDeploy = (
    # only deploy from AppVeyor
    ($env:APPVEYOR_JOB_ID) -and
    # only deploy master branch
    ($env:APPVEYOR_REPO_BRANCH -eq 'master') -and
    # it cannot be a PR
    (-not ($env:APPVEYOR_PULL_REQUEST_NUMBER))
)
# Synopsis: Publish a new release on github, PSGallery and the homepage
task Deploy -If $shouldDeploy PublishToGallery, UpdateHomepage, GeneratePackage

# Synipsis: Publish the $release to the PSGallery
task PublishToGallery {
    assert ($env:PSGalleryAPIKey) "No key for the PSGallery"

    Remove-Module $ModuleName -ErrorAction SilentlyContinue
    Import-Module $ModuleName -ErrorAction Stop
    Publish-Module -Name $ModuleName -NuGetApiKey $env:PSGalleryAPIKey
}

# Synopsis: Create a zip package file of the release
task GeneratePackage {
    Compress-Archive -Path "$releasePath\$ModuleName" -DestinationPath "$releasePath\$($ModuleName)-$($script:Version).zip"
    Write-Host (get-childItem "$releasePath\*.zip" | out-string )
}
# endregion

#region Cleaning tasks
# Synopsis: Clean the working dir
task Clean RemoveGeneratedFiles

# Synopsis: Remove generated and temp files.
task RemoveGeneratedFiles {
    $itemsToRemove = @(
        'Release'
        'TestResult.xml'
    )
    Remove-Item $itemsToRemove -Force -Recurse -ErrorAction 0
}
# endregion

# Synopsis: Deafult task
task . ShowDebug, Clean, Build, Test, Deploy
