#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "[AtlassianPS.MessageStyle] Tests" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
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
