#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe 'Initialize-TestEnvironment' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
    }

    It 'returns the path to the AtlassianPS.Configuration manifest' {
        $path = Initialize-TestEnvironment
        $path | Should -Not -BeNullOrEmpty
        Test-Path $path | Should -BeTrue
        $path | Should -Match '\.psd1$'
    }

    It 'is a no-op when the loaded module already matches the on-disk source' {
        Initialize-TestEnvironment | Out-Null
        $loadedBefore = Get-Module 'AtlassianPS.Configuration'

        $sentinel = [Guid]::NewGuid().ToString()
        & $loadedBefore { param($s) $script:__InitTestSentinel = $s } $sentinel

        Initialize-TestEnvironment | Out-Null
        $loadedAfter = Get-Module 'AtlassianPS.Configuration'
        $survivor = & $loadedAfter { $script:__InitTestSentinel }

        $survivor | Should -Be $sentinel -Because 'a cache hit must not touch the loaded module'
    }

    It 'reimports the module when the cached fingerprint no longer matches' {
        Initialize-TestEnvironment | Out-Null
        $loaded = Get-Module 'AtlassianPS.Configuration'

        & $loaded { $script:__InitTestSentinel = 'should-not-survive' }
        & $loaded { param($fp) $script:__TestImportFingerprint = $fp } 0

        Initialize-TestEnvironment | Out-Null
        $reloaded = Get-Module 'AtlassianPS.Configuration'
        $survivor = & $reloaded { $script:__InitTestSentinel }

        $survivor | Should -BeNullOrEmpty -Because 'a fingerprint mismatch must trigger a fresh import'
    }
}
