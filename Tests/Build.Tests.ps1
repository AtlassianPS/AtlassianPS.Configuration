#requires -modules Pester

Describe "Validation of build environment" {

    BeforeAll {
        Import-Module BuildHelpers
        Remove-Item -Path Env:\BH*
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    $changelogFile = if (Test-Path "$env:BHBuildOutput/CHANGELOG.md") {
        "$env:BHBuildOutput/CHANGELOG.md"
    }
    else {
        "$env:BHProjectPath/CHANGELOG.md"
    }
    assert $changelogFile "no CHANGELOG file"

    $appveyorFile = "$env:BHProjectPath/appveyor.yml"
    assert $appveyorFile "no AppVeyor file"

    Context "CHANGELOG" {

        foreach ($line in (Get-Content $changelogFile)) {
            if ($line -match "(?:##|\<h2.*?\>)\s*(?<Version>(\d+\.?){1,2})") {
                $changelogVersion = $matches.Version
                break
            }
        }

        It "has a changelog file" {
            $changelogFile | Should -Exist
        }

        It "has a valid version in the changelog" {
            $changelogVersion            | Should -Not -BeNullOrEmpty
            [Version]($changelogVersion)  | Should -Not -BeNullOrEmpty
        }

        It "has a version changelog that matches the manifest version" {
            Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion | Should -BeLike "$($changelogVersion.ModuleVersion)*"
        }
    }

    Context "AppVeyor" {

        foreach ($line in (Get-Content $appveyorFile)) {
            # (?<Version>()) - non-capturing group, but named Version. This makes it
            # easy to reference the inside group later.

            if ($line -match '^\D*(?<Version>(\d+\.){1,3}\d+).\{build\}') {
                $appveyorVersion = $matches.Version
                break
            }
        }

        It "has a config file for AppVeyor" {
            $appveyorFile | Should -Exist
        }

        It "has a valid version in the appveyor config" {
            $appveyorVersion           | Should -Not -BeNullOrEmpty
            [Version]($appveyorVersion) | Should -Not -BeNullOrEmpty
        }

        It "has a version for appveyor that matches the manifest version" {
            Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion | Should -BeLike "$($appveyorVersion.ModuleVersion)*"
        }
    }
}
