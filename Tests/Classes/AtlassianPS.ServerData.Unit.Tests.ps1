#requires -modules BuildHelpers
#requires -modules Pester

Describe "[AtlassianPS.ServerType] Tests" -Tag Unit {

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

    It "does not allow for an empty object" {
        { [AtlassianPS.ServerData]::new() } | Should -Throw
        { [AtlassianPS.ServerData]@{} } | Should -Throw
        { New-Object -TypeName AtlassianPS.ServerData } | Should -Throw
    }

    It "throws an error if incomplete data is provided" {
        $session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
        $message = "Must contain Id, Name, Uri and Type."

        { [AtlassianPS.ServerData]@{ } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Id = 1 } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Name = "Name" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Uri = "https://google.com" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Type = "Jira" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Session = $session } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Name = "Name"; Uri = "https://google.com" } } | Should -Throw $message
    }

    It "converts a [Hashtable] to [AtlassianPS.ServerData]" {
        $session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession

        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" } } | Should -Not -Throw
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $session } } | Should -Not -Throw
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $session; Headers = @{ } } } | Should -Not -Throw
    }

    It "has a constructor" {
        { [AtlassianPS.ServerData]::new(1, "Name", "https://google.com", "Jira") } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.ServerData -ArgumentList 1, "Name", "https://google.com", "Jira" } | Should -Not -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" }

        $object.ToString() | Should -Be "Name (https://google.com/)"
    }
}
