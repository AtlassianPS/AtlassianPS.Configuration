#requires -modules InvokeBuild
#requires -modules @{ ModuleName = 'AtlassianPS.Standards'; ModuleVersion = '0.3.0'; MaximumVersion = '0.3.0' }

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingEmptyCatchBlock', '')]
param(
    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [String] $PesterVerbosity = 'Normal',

    [Parameter()]
    [String] $VersionToPublish,

    [String[]]$Tag,
    [String[]]$ExcludeTag = "NotImplemented"
)

$WarningPreference = "Continue"

try {
    $script:IsWindows = (-not (Get-Variable -Name IsWindows -ErrorAction Ignore)) -or $IsWindows
    $script:IsLinux = (Get-Variable -Name IsLinux -ErrorAction Ignore) -and $IsLinux
    $script:IsMacOS = (Get-Variable -Name IsMacOS -ErrorAction Ignore) -and $IsMacOS
    $script:IsCoreCLR = $PSVersionTable.ContainsKey('PSEdition') -and $PSVersionTable.PSEdition -eq 'Core'
}
catch { }

Set-StrictMode -Version Latest

Import-Module "$PSScriptRoot/Tools/BuildTools.psm1" -Force -ErrorAction Stop
Import-Module Metadata -Force -ErrorAction Stop

$ProjectName = 'AtlassianPS.Configuration'
$script:BuildInfo = Initialize-AtlassianPSBuildEnvironment `
    -ProjectName $ProjectName `
    -ProjectPath $PSScriptRoot `
    -VersionToPublish $VersionToPublish `
    -ResetBuildEnvironmentVariables

if ($VersionToPublish) {
    $VersionToPublish = $VersionToPublish.TrimStart('v')
}
$builtManifestPath = $script:BuildInfo.BuiltManifestPath

function Clear-ModuleConfigurationCache {
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


#region SetUp
# Synopsis: Proxy task
task Init { }

# Synopsis: Get the next version for the build
task GetNextVersion {
    $manifestVersion = [Version](Metadata\Get-Metadata -Path $env:BHPSModuleManifest)
    try {
        $env:CurrentOnlineVersion = [Version](Find-Module -Name $env:BHProjectName).Version
        $nextOnlineVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName

        if ( ($manifestVersion.Major -gt $nextOnlineVersion.Major) -or
            ($manifestVersion.Minor -gt $nextOnlineVersion.Minor)
            # -or ($manifestVersion.Build -gt $nextOnlineVersion.Build)
        ) {
            $env:NextBuildVersion = [Version]::New($manifestVersion.Major, $manifestVersion.Minor, 0)
        }
        else {
            $env:NextBuildVersion = $nextOnlineVersion
        }
    }
    catch {
        $env:NextBuildVersion = $manifestVersion
    }
}
#endregion Setup

#region HarmonizeVariables
switch ($true) {
    { $IsWindows } {
        $OS = "Windows"
        if (-not ($IsCoreCLR)) {
            $OSVersion = $PSVersionTable.BuildVersion.ToString()
        }
    }
    { $IsLinux } {
        $OS = "Linux"
    }
    { $IsMacOs } {
        $OS = "OSX"
    }
    { $IsCoreCLR } {
        $OSVersion = $PSVersionTable.OS
    }
}
#endregion HarmonizeVariables

#region DebugInformation
task ShowInfo Init, GetNextVersion, {
    Write-Build Gray
    Write-Build Gray ('Running in:                 {0}' -f $env:BHBuildSystem)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('Project name:               {0}' -f $env:BHProjectName)
    Write-Build Gray ('Project root:               {0}' -f $env:BHProjectPath)
    Write-Build Gray ('Build Path:                 {0}' -f $env:BHBuildOutput)
    Write-Build Gray ('Current (online) Version:   {0}' -f $env:CurrentOnlineVersion)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('Branch:                     {0}' -f $env:BHBranchName)
    Write-Build Gray ('Commit:                     {0}' -f $env:BHCommitMessage)
    Write-Build Gray ('Build #:                    {0}' -f $env:BHBuildNumber)
    Write-Build Gray ('Next Version:               {0}' -f $env:NextBuildVersion)
    Write-Build Gray ('VersionToPublish:           {0}' -f $VersionToPublish)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('PowerShell version:         {0}' -f $PSVersionTable.PSVersion.ToString())
    Write-Build Gray ('OS:                         {0}' -f $OS)
    Write-Build Gray ('OS Version:                 {0}' -f $OSVersion)
    Write-Build Gray
}

# Alias used by shared CI setup actions.
task ShowDebugInfo ShowInfo
#endregion DebugInformation

# Synopsis: Run style checks and PSScriptAnalyzer. Collects both result sets
# before throwing so a single run surfaces every issue. Emits GitHub Actions
# workflow commands when running under CI so violations appear as inline
# annotations on the PR diff.
task Lint {
    $analyzerPaths = @(
        "$env:BHProjectPath/$env:BHProjectName"
        "$env:BHProjectPath/Tests"
        "$env:BHProjectPath/Tools"
        "$env:BHProjectPath/$env:BHProjectName.build.ps1"
    )

    $lintFailures = @()
    try {
        $null = Invoke-AtlassianPSModuleTests `
            -TestPath "$env:BHProjectPath/Tests/Style.Tests.ps1" `
            -PesterVerbosity $PesterVerbosity `
            -MinimumPesterVersion ([Version]'5.9.0') `
            -MaximumPesterVersion ([Version]'5.9.999')
    }
    catch {
        $lintFailures += $_.Exception.Message
    }

    try {
        $null = Invoke-AtlassianPSLint `
            -ProjectPath $env:BHProjectPath `
            -ModulePath $env:BHModulePath `
            -BuildScriptPath "$env:BHProjectPath/$env:BHProjectName.build.ps1" `
            -StyleTestPath "$env:BHProjectPath/Tests/Style.Tests.ps1" `
            -AnalyzerSettingsPath "$env:BHProjectPath/PSScriptAnalyzerSettings.psd1" `
            -AnalyzerPaths $analyzerPaths `
            -PesterVerbosity $PesterVerbosity `
            -Severity @('Error', 'Warning') `
            -SkipStyleTests
    }
    catch {
        $lintFailures += $_.Exception.Message
    }

    if ($lintFailures.Count -gt 0) {
        throw ("Lint failed:`n  - " + ($lintFailures -join "`n  - "))
    }
}

#region BuildRelease
# Synopsis: Build a shippable release
task Build Init, Clean, {
    if (-not (Test-Path "$env:BHBuildOutput/$env:BHProjectName")) {
        $null = New-Item -Path "$env:BHBuildOutput", "$env:BHBuildOutput/$env:BHProjectName" -ItemType Directory
    }
}, GenerateExternalHelp, RemoveOrphanedExternalHelp, CopyModuleFiles, CompileModule, UpdateManifest

# Synopsis: Generate ./Release structure
task CopyModuleFiles {
    Copy-Item -Path "$env:BHModulePath/*" -Destination "$env:BHBuildOutput/$env:BHProjectName" -Recurse -Force
    Copy-Item -Path @(
        "$env:BHProjectPath/CHANGELOG.md"
        "$env:BHProjectPath/LICENSE"
        "$env:BHProjectPath/README.md"
    ) -Destination "$env:BHBuildOutput/$env:BHProjectName" -Force

    $null = New-Item -Path "$env:BHBuildOutput/Tests" -ItemType Directory -ErrorAction SilentlyContinue
    Copy-Item -Path "$env:BHProjectPath/Tests" -Destination $env:BHBuildOutput -Recurse -Force
    Copy-Item -Path "$env:BHProjectPath/Tools" -Destination $env:BHBuildOutput -Recurse -Force
    Copy-Item -Path "$env:BHProjectPath/PSScriptAnalyzerSettings.psd1" -Destination $env:BHBuildOutput -Force
}

# Synopsis: Compile all functions into the .psm1 file
task CompileModule Init, {
    $PublicFunctions = @(
        Get-ChildItem -Path "$env:BHBuildOutput/$env:BHProjectName/Public" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
            Sort-Object -Property FullName
    )
    $PrivateFunctions = @(
        Get-ChildItem -Path "$env:BHBuildOutput/$env:BHProjectName/Private" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
            Sort-Object -Property FullName
    )


    $targetFile = "$env:BHBuildOutput/$env:BHProjectName/$env:BHProjectName.psm1"
    $content = Get-Content -Encoding UTF8 -LiteralPath $targetFile
    $capture = $true
    $compiled = ""

    foreach ($line in $content) {

        if ($line -eq "#region LoadFunctions") {
            $capture = $false

            $compiled += "#region LoadFunctions`r`n"
            foreach ($function in @($PublicFunctions + $PrivateFunctions)) {
                $compiled += "#region $($function.BaseName)`r`n"
                $compiled += (Get-Content -Path $function.FullName -Raw)
                $compiled += "#endregion $($function.BaseName)`r`n"
                $compiled += "`r`n"
            }
        }
        if ($line -eq "#endregion LoadFunctions") {
            $capture = $true
        }

        if ($capture) {
            $compiled += "$line`r`n"
        }
    }

    $utf8Bom = [System.Text.UTF8Encoding]::new($true)
    [System.IO.File]::WriteAllText($targetFile, $compiled, $utf8Bom)

    "Private", "Public" | Foreach-Object { Remove-Item -Path "$env:BHBuildOutput/$env:BHProjectName/$_" -Recurse -Force }
}

# Synopsis: Use PlatyPS to generate External-Help
Task GenerateExternalHelp -Inputs {
    Get-ChildItem "$env:BHProjectPath/docs" -Recurse -File -Filter '*.md'
} -Outputs {
    foreach ($locale in (Get-ChildItem "$env:BHProjectPath/docs" -Attribute Directory)) {
        $localeOut = Join-Path $env:BHModulePath $locale.BaseName

        $hasCommandHelp = Get-ChildItem "$($locale.FullName)/commands/*.md" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'index.md' } |
            Select-Object -First 1
        if ($hasCommandHelp) {
            Join-Path $localeOut "$env:BHProjectName-help.xml"
        }

        Get-ChildItem "$($locale.FullName)/about_*.md" -File -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $localeOut "$($_.BaseName).help.txt" }
    }
} {
    Import-Module Microsoft.PowerShell.PlatyPS -Force

    try {
        foreach ($locale in (Get-ChildItem "$env:BHProjectPath/docs" -Attribute Directory)) {
            $outputPath = "$env:BHModulePath/$($locale.Basename)"
            $null = New-Item -ItemType Directory -Path $outputPath -Force

            $commandHelpFiles = Get-ChildItem "$($locale.FullName)/commands/*.md" -File |
                Where-Object { $_.Name -ne 'index.md' }

            if ($commandHelpFiles) {
                $commandHelp = @($commandHelpFiles | Import-MarkdownCommandHelp)
                $commandHelp | Export-MamlCommandHelp -OutputFolder $outputPath -Force

                # PlatyPS 1.0 still drops the per-command MAML into a nested
                # <ModuleName>/ subdirectory; flatten so the help loader finds it.
                $nestedPath = Join-Path $outputPath $env:BHProjectName
                if (Test-Path $nestedPath) {
                    Get-ChildItem $nestedPath -Filter '*.xml' | Move-Item -Destination $outputPath -Force
                    Remove-Item $nestedPath -Recurse -Force
                }

                $mamlFile = Join-Path $outputPath "$env:BHProjectName-help.xml"
                Assert-True (Test-Path $mamlFile) "Expected MAML help file was not created: $mamlFile"

                # Export-MamlCommandHelp drops `aliases` / `pipelineInput` /
                # `<dev:defaultValue>` even though the markdown YAML and the
                # parsed CommandHelp object both carry them. Splice them back
                # in from the in-memory CommandHelp objects so Get-Help -Full
                # surfaces the same data Import-MarkdownCommandHelp captured.
                $xml = [xml](Get-Content $mamlFile -Raw)
                $ns = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
                $ns.AddNamespace('command', 'http://schemas.microsoft.com/maml/dev/command/2004/10')
                $ns.AddNamespace('dev', 'http://schemas.microsoft.com/maml/dev/2004/10')
                $ns.AddNamespace('maml', 'http://schemas.microsoft.com/maml/2004/10')
                foreach ($help in $commandHelp) {
                    $cmdNode = $xml.SelectSingleNode("//command:command[command:details/command:name='$($help.Title)']", $ns)
                    if (-not $cmdNode) { continue }

                    # Export-MamlCommandHelp dumps every example's full markdown
                    # (fence + prose) into <maml:introduction> and leaves
                    # <dev:code> / <dev:remarks> empty. Get-Help only reads
                    # those two elements, so split the markdown on the first
                    # fenced code block and re-populate them.
                    $exNodes = @($cmdNode.SelectNodes('command:examples/command:example', $ns))
                    for ($i = 0; $i -lt $exNodes.Count -and $i -lt $help.Examples.Count; $i++) {
                        $ex = $exNodes[$i]
                        $remarksMd = $help.Examples[$i].Remarks
                        if (-not $remarksMd) { continue }
                        $codeText = ''
                        $proseText = $remarksMd
                        $fence = [regex]::Match($remarksMd, '(?s)```[a-zA-Z0-9_+\-]*\r?\n(.*?)\r?\n```')
                        if ($fence.Success) {
                            $codeText = $fence.Groups[1].Value.TrimEnd()
                            $proseText = ($remarksMd.Substring(0, $fence.Index) + $remarksMd.Substring($fence.Index + $fence.Length)).Trim()
                        }
                        $intro = $ex.SelectSingleNode('maml:introduction', $ns)
                        if ($intro) { [void]$ex.RemoveChild($intro) }
                        $codeNode = $ex.SelectSingleNode('dev:code', $ns)
                        if (-not $codeNode) {
                            $codeNode = $xml.CreateElement('dev', 'code', 'http://schemas.microsoft.com/maml/dev/2004/10')
                            [void]$ex.AppendChild($codeNode)
                        }
                        $codeNode.InnerText = $codeText
                        $remarksNode = $ex.SelectSingleNode('dev:remarks', $ns)
                        if (-not $remarksNode) {
                            $remarksNode = $xml.CreateElement('dev', 'remarks', 'http://schemas.microsoft.com/maml/dev/2004/10')
                            [void]$ex.AppendChild($remarksNode)
                        }
                        # One <maml:para> per paragraph; Get-Help inserts a
                        # blank line between sibling para elements.
                        while ($remarksNode.HasChildNodes) { [void]$remarksNode.RemoveChild($remarksNode.FirstChild) }
                        foreach ($para in ($proseText -split "\r?\n\r?\n")) {
                            if (-not $para.Trim()) { continue }
                            $pn = $xml.CreateElement('maml', 'para', 'http://schemas.microsoft.com/maml/2004/10')
                            $pn.InnerText = $para
                            [void]$remarksNode.AppendChild($pn)
                        }
                    }

                    $paramMap = @{}
                    foreach ($p in $help.Parameters) { $paramMap[$p.Name] = $p }
                    foreach ($pNode in $cmdNode.SelectNodes('.//command:parameter', $ns)) {
                        $pName = $pNode.SelectSingleNode('maml:name', $ns).InnerText
                        if (-not $paramMap.ContainsKey($pName)) { continue }
                        $p = $paramMap[$pName]
                        $aliasText = if ($p.Aliases) { $p.Aliases -join ', ' } else { 'none' }
                        $pNode.SetAttribute('aliases', $aliasText)
                        $byVal = $false; $byName = $false
                        foreach ($set in $p.ParameterSets) {
                            if ($set.ValueFromPipeline) { $byVal = $true }
                            if ($set.ValueFromPipelineByPropertyName) { $byName = $true }
                        }
                        $pipelineText = if ($byVal -and $byName) {
                            'True (ByValue, ByPropertyName)'
                        }
                        elseif ($byVal) { 'True (ByValue)' }
                        elseif ($byName) { 'True (ByPropertyName)' }
                        else { 'False' }
                        $pNode.SetAttribute('pipelineInput', $pipelineText)
                        # MAML schema places <dev:defaultValue> only on the flat
                        # <command:parameters> entries, not on syntax-item copies.
                        if ($pNode.ParentNode.LocalName -eq 'parameters' -and $p.DefaultValue) {
                            $existing = $pNode.SelectSingleNode('dev:defaultValue', $ns)
                            if ($existing) { $pNode.RemoveChild($existing) | Out-Null }
                            $dv = $xml.CreateElement('dev', 'defaultValue', 'http://schemas.microsoft.com/maml/dev/2004/10')
                            $dv.InnerText = $p.DefaultValue
                            $null = $pNode.AppendChild($dv)
                        }
                    }
                }
                $xml.Save($mamlFile)
            }

            # Copy about topics as help text files. UTF-8 with BOM for PowerShell 5
            # compatibility (matches the CompileModule convention introduced in 3107e3a).
            $utf8Bom = [System.Text.UTF8Encoding]::new($true)
            Get-ChildItem "$($locale.FullName)/about_*.md" -File | ForEach-Object {
                $helpTxtName = $_.BaseName + '.help.txt'
                $content = [System.IO.File]::ReadAllText($_.FullName)
                # Tolerate files where the closing `---` is the final line (no trailing newline).
                $content = $content -replace '\A---\r?\n[\s\S]*?\r?\n---\r?\n?', ''
                [System.IO.File]::WriteAllText((Join-Path $outputPath $helpTxtName), $content, $utf8Bom)
            }
        }
    }
    finally {
        Remove-Module Microsoft.PowerShell.PlatyPS -ErrorAction SilentlyContinue
    }
}

# Synopsis: Remove generated help artifacts whose source markdown no longer exists.
Task RemoveOrphanedExternalHelp {
    if (-not (Test-Path $env:BHModulePath)) { return }
    $docsRoot = Join-Path $env:BHProjectPath 'docs'

    $isHelpOutputDir = {
        param($dir)
        $files = @(Get-ChildItem $dir.FullName -File -ErrorAction SilentlyContinue)
        if ($files.Count -eq 0) { return $false }
        @($files | Where-Object { $_.Name -notlike '*.help.txt' -and $_.Name -notlike '*-help.xml' }).Count -eq 0
    }

    $helpDirs = Get-ChildItem $env:BHModulePath -Directory -ErrorAction SilentlyContinue |
        Where-Object { & $isHelpOutputDir $_ }

    foreach ($localeDir in $helpDirs) {
        $localeDocs = Join-Path $docsRoot $localeDir.Name
        if (-not (Test-Path $localeDocs)) {
            Remove-Item $localeDir.FullName -Recurse -Force
            continue
        }

        $expected = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase)

        $hasCommandHelp = Get-ChildItem (Join-Path $localeDocs 'commands/*.md') -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'index.md' } |
            Select-Object -First 1
        if ($hasCommandHelp) {
            $null = $expected.Add("$env:BHProjectName-help.xml")
        }

        Get-ChildItem (Join-Path $localeDocs 'about_*.md') -File -ErrorAction SilentlyContinue |
            ForEach-Object { $null = $expected.Add("$($_.BaseName).help.txt") }

        Get-ChildItem $localeDir.FullName -File -ErrorAction SilentlyContinue |
            Where-Object { -not $expected.Contains($_.Name) } |
            Remove-Item -Force
    }
}

# Synopsis: Update the manifest of the module
task UpdateManifest {
    Clear-ModuleConfigurationCache
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    Import-Module $env:BHPSModuleManifest -Force
    $ModuleAlias = @(Get-Alias | Where-Object { $_.ModuleName -eq "$env:BHProjectName" })

    $moduleFunctions = [string[]](
        Get-ChildItem "$env:BHModulePath/Public" -Recurse -File -Filter "*.ps1" |
            Sort-Object -Property FullName |
            Select-Object -ExpandProperty BaseName
    )
    Metadata\Update-Metadata -Path $builtManifestPath -PropertyName "FunctionsToExport" -Value @($moduleFunctions)
    Metadata\Update-Metadata -Path $builtManifestPath -PropertyName "AliasesToExport" -Value ''
    if ($ModuleAlias) {
        Metadata\Update-Metadata -Path $builtManifestPath -PropertyName "AliasesToExport" -Value @($ModuleAlias.Name)
    }

    # Keep FunctionsToExport comma spacing stable for PSScriptAnalyzer checks.
    $manifestLines = Get-Content -Path $builtManifestPath
    $manifestLines = $manifestLines | ForEach-Object {
        if ($_ -match '^\s*FunctionsToExport\s*=') {
            $_ -replace "','", "', '"
        }
        else {
            $_
        }
    }
    Set-Content -Path $builtManifestPath -Value $manifestLines -Encoding UTF8
    Remove-Utf8Bom -Path $builtManifestPath
}

# Synopsis: Stamp the planned version into the committed source manifest.
task SetSourceVersion {
    if (-not $script:BuildInfo.VersionToPublish) {
        throw 'VersionToPublish is required for SetSourceVersion. Use -VersionToPublish <semver>.'
    }

    $null = Set-AtlassianPSModuleManifestVersion `
        -BuiltManifestPath $env:BHPSModuleManifest `
        -ModuleName $env:BHProjectName `
        -VersionToPublish $script:BuildInfo.VersionToPublish
}

# Synopsis: Stamp the planned version and release notes into the built artifact.
task SetVersion {
    if (-not $script:BuildInfo.VersionToPublish) {
        throw 'VersionToPublish is required for SetVersion. Use -VersionToPublish <semver>.'
    }

    $releaseNotes = Get-AtlassianPSReleaseNotesFromChangelog `
        -ChangelogPath (Join-Path -Path $env:BHProjectPath -ChildPath 'CHANGELOG.md') `
        -ReleaseVersion $script:BuildInfo.VersionToPublish

    $null = Set-AtlassianPSModuleManifestVersion `
        -BuiltManifestPath $builtManifestPath `
        -ModuleName $env:BHProjectName `
        -VersionToPublish $script:BuildInfo.VersionToPublish `
        -ReleaseNotes $releaseNotes
}

# Synopsis: Create a ZIP file with this build.
task Package {
    $script:PackagePath = New-AtlassianPSModulePackage `
        -BuildOutputPath $env:BHBuildOutput `
        -ModuleName $env:BHProjectName
}

task VerifyReleaseArtifact Package, {
    if (-not $script:BuildInfo.VersionToPublish) {
        throw 'VersionToPublish is required for VerifyReleaseArtifact. Use -VersionToPublish <semver>.'
    }

    $expectedVersion = $script:BuildInfo.VersionToPublish.TrimStart('v')
    $null = Test-AtlassianPSModulePackage `
        -BuildOutputPath $env:BHBuildOutput `
        -ModuleName $env:BHProjectName `
        -PackagePath $script:PackagePath `
        -ExpectedVersion $expectedVersion `
        -RequireReleaseNotes
}

task TestPublish Build, Package, {
    $null = Test-AtlassianPSModulePackage `
        -BuildOutputPath $env:BHBuildOutput `
        -ModuleName $env:BHProjectName `
        -PackagePath $script:PackagePath
}
#endregion BuildRelease

#region Test
task Test Init, {
    Assert-True { Test-Path $env:BHBuildOutput -PathType Container } "Release path must exist"

    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    $requirementsContent = Get-Content `
        -LiteralPath (Join-Path $PSScriptRoot 'Tools/build.requirements.psd1') `
        -Raw
    $pesterMatch = [regex]::Match(
        $requirementsContent,
        'ModuleName\s*=\s*"Pester";\s*RequiredVersion\s*=\s*"(?<Version>[^"]+)"'
    )
    Assert-True $pesterMatch.Success 'Pester must have a pinned RequiredVersion in Tools/build.requirements.psd1.'
    Get-Module Pester | Remove-Module -Force -ErrorAction SilentlyContinue
    Import-Module Pester -RequiredVersion ([Version]$pesterMatch.Groups['Version'].Value) -Force -ErrorAction Stop

    <# $params = @{
        Path    = "$env:BHBuildOutput/$env:BHProjectName"
        Include = '*.ps1', '*.psm1'
        Recurse = $True
        Exclude = $CodeCoverageExclude
    }
    $codeCoverageFiles = Get-ChildItem @params #>

    $pesterConfigHash = @{
        Run        = @{
            PassThru = $true
            Path     = "$env:BHBuildOutput/Tests"
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = 'NUnitXml'
            OutputPath   = "$env:BHProjectPath/Test-$OS-$($PSVersionTable.PSVersion.ToString()).xml"
        }
        Output     = @{
            Verbosity = $PesterVerbosity
        }
        Filter     = @{
            ExcludeTag = @($ExcludeTag)
        }
        # CodeCoverage = @{
        #     Path = $codeCoverageFiles
        # }
    }

    if ($Tag) {
        $pesterConfigHash.Filter.Tag = $Tag
        $pesterConfigHash.Filter.ExcludeTag = @($pesterConfigHash.Filter.ExcludeTag | Where-Object { $_ -notin $Tag })
        Write-Build Gray "Filtering tests by tag(s): $($Tag -join ', ')"
    }

    if ($ExcludeTag) {
        $merged = @($pesterConfigHash.Filter.ExcludeTag) + @($ExcludeTag) | Select-Object -Unique
        if ($Tag) {
            $merged = @($merged | Where-Object { $_ -notin $Tag })
        }
        $pesterConfigHash.Filter.ExcludeTag = $merged
        Write-Build Gray "Excluding tests by tag(s): $($pesterConfigHash.Filter.ExcludeTag -join ', ')"
    }

    $pesterConfig = New-PesterConfiguration -Hashtable $pesterConfigHash
    $testResults = Invoke-Pester -Configuration $pesterConfig

    Assert-True ($testResults.FailedCount -eq 0) "$($testResults.FailedCount) Pester test(s) failed."
}

#endregion

#region Cleaning tasks
# Synopsis: Clean the working dir
task Clean {
    Remove-Item $env:BHBuildOutput -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "Test*.xml" -Force -ErrorAction SilentlyContinue
    # Keep $env:BHModulePath/<locale>/ as GenerateExternalHelp cache.
}
#endregion

task . ShowInfo, Clean, Build, Test
