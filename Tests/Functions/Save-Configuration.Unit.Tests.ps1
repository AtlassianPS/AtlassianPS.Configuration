#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Save-Configuration" -Tag Unit {

    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }
    InModuleScope "AtlassianPS.Configuration" {

        BeforeEach {
            #region Mocking
            Mock Write-DebugMessage -ModuleName "AtlassianPS.Configuration" {}
            Mock Write-Verbose -ModuleName "AtlassianPS.Configuration" {}

            function ExportConfiguration {
                param($InputObject)
                $InputObject
            }
            Mock Import-MqcnAlias -ModuleName "AtlassianPS.Configuration" {}
            Mock ExportConfiguration -ModuleName "AtlassianPS.Configuration" {
                param($InputObject)
                $InputObject
            }

            Mock Get-Configuration -ModuleName "AtlassianPS.Configuration" {
                @{
                    Foo        = "lorem ipsum"
                    Bar        = 42
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
        }

        Context "Sanity checking" { }

        Context "Behavior checking" {

            It "does not fail on invocation" {
                { Save-Configuration } | Should -Not -Throw
            }

            It "uses the Configuration module to export the data" {
                Save-Configuration

                Should -Invoke "ExportConfiguration" -ModuleName "AtlassianPS.Configuration" -Exactly -Times 1 -Scope It
            }

            It "exports all keys in the configuration" {
                $after = Save-Configuration

                $after["Foo"] | Should -Not -BeNullOrEmpty
                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -Not -BeNullOrEmpty
                $after["Bar"] | Should -BeOfType [Int]
                $after["ServerList"] | Should -Not -BeNullOrEmpty
                ($after["ServerList"] | Select-Object -First 1) | Should -BeOfType [AtlassianPS.ServerData]
                $after["ServerList"] | Should -HaveCount 2
            }

            It "does not allow sessions to be exported" {
                $before = Get-Configuration
                $after = Save-Configuration

                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -BeOfType [Int]
                ($before["ServerList"] | Where-Object Session | Select-Object -First 1).Session.UserAgent | Should -Not -BeNullOrEmpty
                ($after["ServerList"] | Where-Object Name -eq "Google with Session" | Select-Object -First 1).Session | Should -BeNullOrEmpty
            }
        }
    }
}
