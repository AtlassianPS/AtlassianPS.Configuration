#requires -modules Pester

Describe "[AtlassianPS.ServerData] Tests" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\..\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
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
