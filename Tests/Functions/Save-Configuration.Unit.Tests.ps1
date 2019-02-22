#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Save-Configuration" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope $env:BHProjectName {

        #region Mocking
        Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
        Mock Write-Verbose -ModuleName $env:BHProjectName {}
        Mock Import-MqcnAlias -ModuleName $env:BHProjectName {}

        function ExportConfiguration($InputObject) {}
        Mock ExportConfiguration {
            $InputObject
        }

        Mock Get-Configuration {
            @{
                Foo = "lorem ipsum"
                Bar = 42
                ServerList = @(
                    [AtlassianPS.ServerData]@{
                        Id   = 1
                        Name = "Google"
                        Uri  = "https://google.com"
                        Type = "Jira"
                    }
                    [AtlassianPS.ServerData]@{
                        Id      = 2
                        Name    = "Google with Session"
                        Uri     = "https://google.com"
                        Type    = "Jira"
                        Session = (New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession)
                    }
                )
            }
        }
        #endregion Mocking

        Context "Sanity checking" { }

        Context "Behavior checking" {

            It "does not fail on invocation" {
                { Save-Configuration } | Should -Not -Throw
            }

            It "uses the Configuration module to export the data" {
                Save-Configuration

                Assert-MockCalled -CommandName "ExportConfiguration" -ModuleName $env:BHProjectName -Exactly -Times 1 -Scope It
            }

            It "exports all keys in the configuration" {
                $after = Save-Configuration

                $after["Foo"] | Should -Not -BeNullOrEmpty
                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -Not -BeNullOrEmpty
                $after["Bar"] | Should -BeOfType [Int]
                $after["ServerList"] | Should -Not -BeNullOrEmpty
                $after["ServerList"] | Should -BeOfType [AtlassianPS.ServerData]
                $after["ServerList"] | Should -HaveCount 2
            }

            It "does not allow sessions to be exported" {
                $before = Get-Configuration
                $after = Save-Configuration

                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -BeOfType [Int]
                $before["ServerList"].Session.UserAgent | Should -Not -BeNullOrEmpty
                $after.ServerList.Session.UserAgent | Should -BeNullOrEmpty
            }
        }
    }
}
