#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "[AtlassianPS.ServerData] Tests" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
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

    Context "Types of properties" {
        $object = [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" }

        It "has a Id of type UInt32" {
            $object.Id | Should -BeOfType [UInt32]
        }

        It "has a Name of type String" {
            $object.Name | Should -BeOfType [String]
        }

        It "has a Uri of type Uri" {
            $object.Uri | Should -BeOfType [Uri]
        }

        It "has a Type of type AtlassianPS.ServerType" {
            $object.Type | Should -BeOfType [AtlassianPS.ServerType]
        }
    }
}
