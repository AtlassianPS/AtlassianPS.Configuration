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

    # ARRANGE
    $session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
    $certificate = Get-ChildItem -Path "Cert:\LocalMachine\" -Recurse |
        Where-Object { $_.GetType().Name -eq "X509Certificate2" } |
        Select-Object -First 1

    It "does not allow for an empty object" {
        { [AtlassianPS.ServerData]::new() } | Should -Throw
        { [AtlassianPS.ServerData]@{} } | Should -Throw
        { New-Object -TypeName AtlassianPS.ServerData } | Should -Throw
    }

    It "throws an error if incomplete data is provided" {
        $message = "Must contain Id, Name, Uri and Type."

        { [AtlassianPS.ServerData]@{ } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Id = 1 } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Name = "Name" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Uri = "https://google.com" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Type = "Jira" } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Session = $session } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$certificate } } | Should -Throw $message
        { [AtlassianPS.ServerData]@{ Name = "Name"; Uri = "https://google.com" } } | Should -Throw $message
    }

    It "converts a [Hashtable] to [AtlassianPS.ServerData]" {
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" } } | Should -Not -Throw
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $session } } | Should -Not -Throw
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $session; Headers = @{ } } } | Should -Not -Throw
        { [AtlassianPS.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $session; Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$certificate ; Headers = @{ } } } | Should -Not -Throw
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
        $object = [AtlassianPS.ServerData]@{
            Id = 1
            Name = "Name"
            Uri = "https://google.com"
            Type = "Jira"
            Session = $session
            Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$certificate
            Headers = @{ }
        }

        It "has a Id of type UInt32" {
            $object.Id | Should -BeOfType [UInt32]
        }

        It "has a Name of type String" {
            $object.Name | Should -BeOfType [String]
        }

        It "has a Uri of type Uri" {
            $object.Uri | Should -BeOfType [Uri]
        }

        It "has a Certificate of type X509Certificate" {
            $object.Certificate | Should -BeOfType [X509Certificate]
        }

        It "has a Type of type AtlassianPS.ServerType" {
            $object.Type | Should -BeOfType [AtlassianPS.ServerType]
        }
    }
}
