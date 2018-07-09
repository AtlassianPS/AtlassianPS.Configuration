#requires -modules BuildHelpers
#requires -modules Pester

Describe "[AtlassianPS.ServerData] Tests" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/../..").Path
        if ($projectRoot -like "*Release") {
            $projectRoot = (Resolve-Path "$projectRoot/..").Path
        }

        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

        $env:BHManifestToTest = $env:BHPSModuleManifest
        $script:isBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
        if ($script:isBuild) {
            $Pattern = [regex]::Escape($env:BHProjectPath)

            $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
            $env:BHManifestToTest = $env:BHBuildModuleManifest
        }

        Import-Module "$env:BHProjectPath/Tools/build.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    It "creates an [AtlassianPS.ServerType] from a string" {
        { [AtlassianPS.ServerType]"bitbucket" } | Should -Not -Throw
        { [AtlassianPS.ServerType]"confluence" } | Should -Not -Throw
        { [AtlassianPS.ServerType]"jira" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPS.ServerType]"foo" } | Should -Throw 'Cannot convert value "foo" to type "AtlassianPS.ServerType"'
    }

    It "has no constructor" {
        { [AtlassianPS.ServerType]::new("Jira") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ServerType -ArgumentList "Jira" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPS.ServerType')

        $values.Count | Should -Be 3
        $values | Should -Contain "BITBUCKET"
        $values | Should -Contain "CONFLUENCE"
        $values | Should -Contain "JIRA"
    }
}
