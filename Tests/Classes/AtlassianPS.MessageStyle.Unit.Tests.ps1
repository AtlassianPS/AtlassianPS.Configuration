#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "[AtlassianPS.MessageStyle] Tests" -Tag Unit {

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

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    It "allows for an empty object" {
        { [AtlassianPS.MessageStyle]::new() } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]@{} } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.MessageStyle } | Should -Not -Throw
    }

    It "converts a [Hashtable] to [AtlassianPS.MessageStyle]" {
        $session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession

        { [AtlassianPS.MessageStyle]@{ Indent = 0 } } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]@{ Indent = 0; TimeStamp = $true; } } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]@{ Indent = 0; TimeStamp = $true; BreadCrumbs = $true } } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]@{ Indent = 0; TimeStamp = $true; BreadCrumbs = $true; FunctionName = $true } } | Should -Not -Throw
    }

    It "has a constructor" {
        { [AtlassianPS.MessageStyle]::new() } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]::new(0, $true, $true, $true) } | Should -Not -Throw
        { [AtlassianPS.MessageStyle]::new(0, $true, $true) } | Should -Throw
        { [AtlassianPS.MessageStyle]::new(0, $true) } | Should -Throw
        { [AtlassianPS.MessageStyle]::new(0) } | Should -Throw
        { New-Object -TypeName AtlassianPS.MessageStyle -ArgumentList 0, $true, $true, $true } | Should -Not -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPS.MessageStyle]@{}

        $object.ToString() | Should -Be "AtlassianPS.MessageStyle"
    }
}
