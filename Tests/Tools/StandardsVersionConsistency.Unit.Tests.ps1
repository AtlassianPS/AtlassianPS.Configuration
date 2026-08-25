#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe 'AtlassianPS.Standards version consistency' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:projectRoot = Resolve-ProjectRoot
        $script:standardsActionSha = '8a75c583308d27526f29d7aaef1d1ba67c059103'

        $requirementsPath = Join-Path $script:projectRoot 'Tools/build.requirements.psd1'
        $requirements = Import-PowerShellDataFile -Path $requirementsPath
        $standardsRequirement = $requirements |
            Where-Object ModuleName -EQ 'AtlassianPS.Standards' |
            Select-Object -First 1
        $script:standardsVersion = [string]$standardsRequirement.RequiredVersion
    }

    It 'pins every Standards workflow dependency to the released build dependency' {
        $workflowRoot = Join-Path $script:projectRoot '.github/workflows'
        $matches = foreach ($workflow in Get-ChildItem $workflowRoot -Filter '*.yml') {
            $content = Get-Content -LiteralPath $workflow.FullName -Raw
            [regex]::Matches(
                $content,
                'AtlassianPS/AtlassianPS\.Standards/\.github/(?:actions/[^\s@]+|workflows/module_release\.yml)@(?<sha>[0-9a-f]{40})\s+#\s+v(?<version>\d+\.\d+\.\d+)'
            )
        }

        @($matches).Count | Should -BeGreaterThan 0
        @($matches | ForEach-Object { $_.Groups['sha'].Value } | Select-Object -Unique) |
            Should -Be @($script:standardsActionSha)
        @($matches | ForEach-Object { $_.Groups['version'].Value } | Select-Object -Unique) |
            Should -Be @($script:standardsVersion)
    }

    It 'grants the shared release workflow issue read access' {
        $workflow = Get-Content (Join-Path $script:projectRoot '.github/workflows/continuous_release.yml') -Raw

        $workflow | Should -Match 'issues:\s+read'
        $workflow | Should -Match 'workflows/module_release\.yml@[0-9a-f]{40}'
    }

    It 'keeps the build script requirement aligned with build.requirements' {
        $buildScript = Get-Content (Join-Path $script:projectRoot 'AtlassianPS.Configuration.build.ps1') -Raw
        $escapedVersion = [regex]::Escape($script:standardsVersion)

        $buildScript | Should -Match "ModuleName\s*=\s*'AtlassianPS\.Standards';\s*ModuleVersion\s*=\s*'$escapedVersion';\s*MaximumVersion\s*=\s*'$escapedVersion'"
    }

    It 'reads the Standards version from build.requirements in dependency tools' {
        $setupScript = Get-Content (Join-Path $script:projectRoot 'Tools/setup.ps1') -Raw
        $updateScript = Get-Content (Join-Path $script:projectRoot 'Tools/update.dependencies.ps1') -Raw

        $setupScript | Should -Match '\$buildRequirements\s*=\s*Import-PowerShellDataFile'
        $setupScript | Should -Match '-RequiredVersion\s+\$standardsVersion'
        $updateScript | Should -Match '\$buildRequirements\s*=\s*Import-PowerShellDataFile'
        $updateScript | Should -Match 'AtlassianPS\.Standards\\Update-AtlassianPSDependencyReference'
    }

    It 'loads the pinned Pester version before running the test task' {
        $buildScript = Get-Content (Join-Path $script:projectRoot 'AtlassianPS.Configuration.build.ps1') -Raw

        $buildScript | Should -Match "ModuleName\\s\*=\\s\*`"Pester`""
        $buildScript | Should -Match 'Import-Module Pester -RequiredVersion'
    }
}
