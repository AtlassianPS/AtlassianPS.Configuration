#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "[AtlassianPS.ServerType] Tests" -Tag Unit {

    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    It "creates an [AtlassianPS.ServerType] from a string" {
        { [AtlassianPS.ServerType]"bitbucket" } | Should -Not -Throw
        { [AtlassianPS.ServerType]"confluence" } | Should -Not -Throw
        { [AtlassianPS.ServerType]"jira" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPS.ServerType]"foo" } | Should -Throw -Because "InvalidArgument"
    }

    It "has no constructor" {
        { [AtlassianPS.ServerType]::new("Jira") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ServerType -ArgumentList "Jira" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPS.ServerType')

        $values | Should -HaveCount 3
        $values | Should -Contain "BITBUCKET"
        $values | Should -Contain "CONFLUENCE"
        $values | Should -Contain "JIRA"
    }
}
