#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe 'GitHub Actions release contract' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:projectRoot = Resolve-ProjectRoot
        $workflowRoot = Join-Path $script:projectRoot '.github/workflows'
        $script:ci = Get-Content (Join-Path $workflowRoot 'ci.yml') -Raw
        $script:continuousRelease = Get-Content (Join-Path $workflowRoot 'continuous_release.yml') -Raw
        $script:releaseIntent = Get-Content (Join-Path $workflowRoot 'release_intent.yml') -Raw
    }

    It 'pins every external action to a full commit SHA' {
        foreach ($workflow in Get-ChildItem (Join-Path $script:projectRoot '.github/workflows') -Filter '*.yml') {
            $content = Get-Content -LiteralPath $workflow.FullName -Raw
            $actionReferences = [regex]::Matches($content, '(?m)^\s*-\s+uses:\s+(?<action>[^@\s]+)@(?<ref>[^\s#]+)')

            foreach ($reference in $actionReferences) {
                $reference.Groups['ref'].Value | Should -Match '^[0-9a-f]{40}$' -Because $workflow.Name
            }
        }
    }

    It 'validates release intent using only the immutable remote action' {
        $script:releaseIntent | Should -Match '(?m)^\s+pull_request_target:'
        $script:releaseIntent | Should -Match 'AtlassianPS/AtlassianPS\.Standards/\.github/actions/validate-release-intent@'
        $script:releaseIntent | Should -Match '(?m)^\s+pull-requests:\s+read\r?$'
        $script:releaseIntent | Should -Match '(?m)^\s+issues:\s+write\r?$'
        $script:releaseIntent | Should -Not -Match 'actions/checkout@|contents:\s+write|pull_request\.head|github\.head_ref'
    }

    It 'builds and verifies the candidate without publishing credentials' {
        $script:ci | Should -Match 'AtlassianPS/AtlassianPS\.Standards/\.github/actions/build-release-notes@'
        $script:ci | Should -Match 'Invoke-Build -Task SetVersion'
        $script:ci | Should -Match 'Invoke-Build -Task VerifyReleaseArtifact'
        $script:ci | Should -Match 'name:\s+Release'
        $script:ci | Should -Not -Match 'PSGALLERY_API_KEY|ATLASSIANPS_RELEASE_APP|HOMEPAGE_PAT'
    }

    It 'promotes only the exact tested artifact' {
        $publishJob = [regex]::Match($script:continuousRelease, '(?ms)^  publish:\s*\r?\n(?<body>.*)\z').Groups['body'].Value

        $publishJob | Should -Match 'actions/download-artifact@[0-9a-f]{40}'
        $publishJob | Should -Match 'run-id:\s+\$\{\{\s*github\.event\.workflow_run\.id\s*\}\}'
        $publishJob | Should -Match 'digest-mismatch:\s+error'
        $publishJob | Should -Not -Match 'actions/checkout@|uses:\s+\./|Invoke-Build'

        $tagIndex = $publishJob.IndexOf('Create annotated release tag')
        $publishIndex = $publishJob.IndexOf('Publish-Module -Path ./Release/AtlassianPS.Configuration')
        $releaseIndex = $publishJob.IndexOf('softprops/action-gh-release')
        $tagIndex | Should -BeGreaterOrEqual 0
        $publishIndex | Should -BeGreaterThan $tagIndex
        $releaseIndex | Should -BeGreaterThan $publishIndex
    }

    It 'keeps publication idempotent and uses Publish-Module directly' {
        $script:continuousRelease | Should -Match 'Find-Module -Name ''AtlassianPS\.Configuration'' -RequiredVersion \$expectedGalleryVersion -Repository PSGallery'
        $script:continuousRelease | Should -Match 'Publish-Module -Path ./Release/AtlassianPS\.Configuration -Repository PSGallery'
        $script:continuousRelease | Should -Match 'body_path:\s+\./Release/release-notes\.md'
        $script:continuousRelease | Should -Match 'repository:\s+AtlassianPS/AtlassianPS\.github\.io'
    }

    It 'removes the legacy tag-triggered release path' {
        Test-Path (Join-Path $script:projectRoot '.github/workflows/release.yml') | Should -BeFalse
        $script:continuousRelease | Should -Not -Match '(?m)^\s+tags:'
    }

    It 'keeps source release notes empty and release build responsibilities focused' {
        $manifest = Get-Content (Join-Path $script:projectRoot 'AtlassianPS.Configuration/AtlassianPS.Configuration.psd1') -Raw
        $buildScript = Get-Content (Join-Path $script:projectRoot 'AtlassianPS.Configuration.build.ps1') -Raw

        $manifest | Should -Match "ReleaseNotes\s*=\s*''"
        $buildScript | Should -Match 'task SetSourceVersion'
        $buildScript | Should -Match 'task VerifyReleaseArtifact'
        $buildScript | Should -Not -Match '(?m)^task Publish\b|PSGalleryAPIKey'
    }

    It 'labels future Dependabot updates as non-releasing changes' {
        $dependabot = Get-Content (Join-Path $script:projectRoot '.github/dependabot.yml') -Raw

        $dependabot | Should -Match '(?m)^\s+- dependencies\r?$'
        $dependabot | Should -Match '(?m)^\s+- github_actions\r?$'
        $dependabot | Should -Match '(?m)^\s+- "release:none"\r?$'
    }
}
