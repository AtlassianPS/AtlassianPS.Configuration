#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe "Validation of build environment" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"

        $script:moduleToTest = Initialize-TestEnvironment
        $script:moduleRoot = Resolve-ProjectRoot
    }

    Context "Compiled module" {
        It "has a UTF-8 BOM on the compiled .psm1" {
            $modulePath = Split-Path $moduleToTest -Parent
            $psm1Path = Join-Path $modulePath "$((Get-Item $modulePath).Name).psm1"
            $bytes = [System.IO.File]::ReadAllBytes($psm1Path)
            $bytes.Count | Should -BeGreaterThan 3
            $bytes[0] | Should -Be 0xEF
            $bytes[1] | Should -Be 0xBB
            $bytes[2] | Should -Be 0xBF
        }
    }

    Context "Profile safety" {
        It "uses disposable paths after Configuration reimport and preserves profile files" {
            $sentinel = Join-Path $TestDrive 'Configuration.psd1'
            Set-Content -LiteralPath $sentinel -Value 'saved-profile-sentinel'
            $before = (Get-FileHash -LiteralPath $sentinel).Hash
            Remove-Module AtlassianPS.Configuration, Configuration -Force -ErrorAction SilentlyContinue
            Import-Module $moduleToTest -ErrorAction Stop
            foreach ($scope in @('User', 'Enterprise', 'Machine')) {
                $path = Configuration\Get-ConfigurationPath -CompanyName AtlassianPS -Name AtlassianPS.Configuration -Scope $scope
                $path | Should -BeLike ($env:ATLASSIANPS_CONFIGURATION_ROOT + '*')
            }
            (Get-FileHash -LiteralPath $sentinel).Hash | Should -Be $before
        }

        It "does not retain real-profile cleanup entry points" {
            foreach ($relative in @('AtlassianPS.Configuration.build.ps1', 'Tests/Helpers/TestTools.ps1')) {
                Get-Content -LiteralPath (Join-Path $moduleRoot $relative) -Raw |
                    Should -Not -Match 'Clear-(Module|Test)ConfigurationCache'
            }
        }
    }

    Context "Pester result gate" {
        It "includes test, block, and container failures" {
            $buildScript = Get-Content -LiteralPath (Join-Path $moduleRoot 'AtlassianPS.Configuration.build.ps1') -Raw

            $buildScript | Should -Match '\$testResults\.FailedCount \+ \$testResults\.FailedBlocksCount \+ \$testResults\.FailedContainersCount'
        }
    }

    Context "CHANGELOG" {
        BeforeAll {
            $changelogFile = "$moduleRoot/CHANGELOG.md"

            if (-not (Test-Path $changelogFile)) {
                throw "CHANGELOG.md file not found in the module root directory."
            }

            $script:changelogVersion = $null
            foreach ($line in (Get-Content $changelogFile)) {
                if ($line -match "(?:##|\<h2.*?\>)\s*v?(?<Version>\d+\.\d+\.\d+)(\-(?<Prerelease>(?:alpha|beta|rc)\d*))?") {
                    $changelogVersion = $matches.Version
                    break
                }
            }
        }

        It "has a changelog file" {
            $changelogFile | Should -Exist
        }

        It "has a valid version in the changelog" {
            $changelogVersion | Should -Not -BeNullOrEmpty
            [Version]($changelogVersion) | Should -BeOfType [Version]
        }

        It "has a version changelog that matches the manifest version" {
            Metadata\Get-Metadata -Path $moduleToTest -PropertyName ModuleVersion | Should -BeLike "$changelogVersion*"
        }
    }
}
