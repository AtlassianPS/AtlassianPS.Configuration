#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe "Remove-Configuration" -Tag Unit {
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
            Mock Save-Configuration -ModuleName "AtlassianPS.Configuration" {}

            Mock Get-Configuration {
                $tempConfig = $script:Configuration.Clone()
                $tempConfig.Keys |
                    ForEach-Object {
                        [PSCustomObject]@{
                            Name  = $_
                            Value = $tempConfig[$_]
                        }
                    }
            }
            #endregion Mocking
        }

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name Remove-Configuration
            }

            It "has a mandatory parameter 'Name' of type [String[]] with ArgumentCompleter" {
                $command | Should -HaveParameter "Name" -Mandatory -Type [String[]] -HasArgumentCompleter
            }
        }

        Context "Behavior checking" {
            #region Arrange
            BeforeEach {
                $script:Configuration = @{
                    Foo        = "lorem ipsum"
                    Bar        = 42
                    Baz        = (Get-Date)
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
            #endregion Arrange

            It "removes one entry of the configuration" {
                Get-Configuration | Should -HaveCount 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "Foo"

                Get-Configuration | Should -HaveCount 3
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
            }

            It "does not remove or save a configuration key when WhatIf is used" {
                Remove-Configuration -Name "Foo" -WhatIf

                Get-Configuration | Should -HaveCount 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Should -Invoke "Save-Configuration" -ModuleName "AtlassianPS.Configuration" -Exactly -Times 0 -Scope It
            }

            It "removes multiple entries at once" {
                Get-Configuration | Should -HaveCount 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Baz" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "Foo", "Bar"

                Get-Configuration | Should -HaveCount 2
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Baz" | Should -Not -BeNullOrEmpty
            }

            It "accepts an object over the pipeline" {
                Get-Configuration | Should -HaveCount 4

                Get-Configuration |
                    Where-Object Name -ne "ServerList" |
                    Remove-Configuration

                Get-Configuration | Should -HaveCount 1
                Get-Configuration | Where-Object Name -eq "ServerList" | Should -Not -BeNullOrEmpty
            }

            It "accepts strings over the pipeline" {
                Get-Configuration | Should -HaveCount 4

                "Foo", "Bar" | Remove-Configuration

                Get-Configuration | Should -HaveCount 2
            }

            It "is not case sensitive" {
                Get-Configuration | Should -HaveCount 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "foo"

                Get-Configuration | Should -HaveCount 3
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
            }

            It "does not allow reserved configuration keys to be removed" {
                { Remove-Configuration -Name "ServerList" -ErrorAction Stop } | Should -Throw

                Get-Configuration | Where-Object Name -eq "ServerList" | Should -Not -BeNullOrEmpty
            }

            It "allows the Message configuration key to be removed" {
                $script:Configuration["Message"] = [AtlassianPS.MessageStyle]::new()

                Remove-Configuration -Name "Message"

                Get-Configuration | Where-Object Name -eq "Message" | Should -BeNullOrEmpty
            }
        }
    }
}
