#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe 'AtlassianPS.Standards version consistency' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:projectRoot = Resolve-ProjectRoot
    }

    It 'keeps workflow setup action pins aligned with build.requirements' {
        $buildRequirementsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools/build.requirements.psd1'
        $buildRequirements = Import-PowerShellDataFile -Path $buildRequirementsPath
        $standardsRequirement = $buildRequirements |
            Where-Object { $_.ModuleName -eq 'AtlassianPS.Standards' } |
            Select-Object -First 1
        $standardsVersion = [string] $standardsRequirement.RequiredVersion

        $workflowPaths = Get-ChildItem -Path (Join-Path -Path $script:projectRoot -ChildPath '.github/workflows') -File -Filter '*.yml' |
            Select-Object -ExpandProperty FullName

        $workflowActionMatches = foreach ($workflowPath in $workflowPaths) {
            $workflowContent = Get-Content -LiteralPath $workflowPath -Raw
            [regex]::Matches(
                $workflowContent,
                "AtlassianPS/AtlassianPS\.Standards/\.github/actions/setup-powershell@(?<sha>[0-9a-f]{40})(?:\s+#\s+v(?<version>[0-9]+\.[0-9]+\.[0-9]+))?"
            ) | ForEach-Object {
                [PSCustomObject]@{
                    WorkflowPath = $workflowPath
                    Sha          = $_.Groups['sha'].Value
                    Version      = $_.Groups['version'].Value
                }
            }
        }

        @($workflowActionMatches).Count | Should -BeGreaterThan 0
        @($workflowActionMatches | Select-Object -ExpandProperty Sha -Unique).Count | Should -Be 1

        $matchedVersions = @(
            $workflowActionMatches |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.Version) } |
                Select-Object -ExpandProperty Version -Unique
        )
        if ($matchedVersions.Count -gt 0) {
            $matchedVersions.Count | Should -Be 1
            $matchedVersions[0] | Should -Be $standardsVersion
        }
    }

    It 'uses the same standards version in build script and release workflow publish orchestration' {
        $buildRequirementsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools/build.requirements.psd1'
        $buildRequirements = Import-PowerShellDataFile -Path $buildRequirementsPath
        $standardsRequirement = $buildRequirements |
            Where-Object { $_.ModuleName -eq 'AtlassianPS.Standards' } |
            Select-Object -First 1
        $standardsVersion = [string] $standardsRequirement.RequiredVersion

        $buildScriptContent = Get-Content -LiteralPath (Join-Path -Path $script:projectRoot -ChildPath 'AtlassianPS.Configuration.build.ps1') -Raw
        $buildScriptContent | Should -Match "ModuleName\s*=\s*'AtlassianPS\.Standards';\s*ModuleVersion\s*=\s*'$([regex]::Escape($standardsVersion))';\s*MaximumVersion\s*=\s*'$([regex]::Escape($standardsVersion))'"

        $releaseWorkflowContent = Get-Content -LiteralPath (Join-Path -Path $script:projectRoot -ChildPath '.github/workflows/release.yml') -Raw
        $releaseWorkflowContent | Should -Match "Invoke-Build\s+-Task\s+Publish\s+-VersionToPublish\s+\$\{\{\s*steps\.release_ref\.outputs\.release_tag\s*\}\}"
        $releaseWorkflowContent | Should -Match '-PSGalleryAPIKey\s+\$\{\{\s*secrets\.PSGALLERY_API_KEY\s*\}\}'
        $releaseWorkflowContent | Should -Not -Match 'Import-Module\s+AtlassianPS\.Standards\s+-RequiredVersion'
    }

    It 'reads AtlassianPS.Standards version from build.requirements in tool scripts' {
        $setupScriptContent = Get-Content -LiteralPath (Join-Path -Path $script:projectRoot -ChildPath 'Tools/setup.ps1') -Raw
        $updateScriptContent = Get-Content -LiteralPath (Join-Path -Path $script:projectRoot -ChildPath 'Tools/update.dependencies.ps1') -Raw

        $setupScriptContent | Should -Match '\$buildRequirements\s*=\s*Import-PowerShellDataFile'
        $setupScriptContent | Should -Not -Match '\$standardsVersion\s*=\s*''[^'']+'''
        $setupScriptContent | Should -Match '-RequiredVersion\s+\$standardsVersion'

        $updateScriptContent | Should -Match '\$buildRequirements\s*=\s*Import-PowerShellDataFile'
        $updateScriptContent | Should -Not -Match '\$standardsVersion\s*=\s*''[^'']+'''
        $updateScriptContent | Should -Match '-RequiredVersion\s+\$standardsVersion'
        $updateScriptContent | Should -Match '\$PSCmdlet\.ShouldProcess\('
        $updateScriptContent | Should -Match 'AtlassianPS\.Standards\\Update-AtlassianPSDependencyReference'
    }
}
