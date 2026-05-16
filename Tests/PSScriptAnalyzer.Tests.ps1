#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }
#requires -modules @{ ModuleName = 'PSScriptAnalyzer'; ModuleVersion = '1.25.0' }

Describe "PSScriptAnalyzer Tests" -Tag Build {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        $projectRoot = if ($env:BHisBuild) { $env:BHBuildOutput } else { $env:BHProjectPath }
        $modulePath = Join-Path $projectRoot "AtlassianPS.Configuration"
        $settingsPath = Join-Path $projectRoot "PSScriptAnalyzerSettings.psd1"

        $params = @{
            Path        = $modulePath
            Settings    = $settingsPath
            Severity    = @('Error', 'Warning')
            Recurse     = $true
            Verbose     = $false
            ErrorAction = 'SilentlyContinue'
        }

        $script:analyzerErrors = @()
        $script:scriptWarnings = Invoke-ScriptAnalyzer @params -ErrorVariable +script:analyzerErrors
    }

    AfterAll {
        Invoke-TestCleanup
    }

    It "has no rule violations" {
        $scriptWarnings | Should -BeNullOrEmpty
    }

    It "has no parse errors" {
        $analyzerErrors | Should -BeNullOrEmpty
    }
}
