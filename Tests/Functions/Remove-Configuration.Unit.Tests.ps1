#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Remove-Configuration" -Tag Unit {

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
        Mock Save-Configuration -ModuleName $env:BHProjectName {}

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

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-Configuration

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

                Get-Configuration | Remove-Configuration

                Get-Configuration | Should -HaveCount 0
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
        }
    }
}
