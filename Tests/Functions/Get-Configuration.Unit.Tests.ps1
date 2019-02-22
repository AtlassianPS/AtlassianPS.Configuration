#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-Configuration" -Tag Unit {

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
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Get-Configuration

            It "has a parameter 'Name' of type [String[]] with ArgumentCompleter and a default value '*'" {
                $command | Should -HaveParameter "Name" -Type [String[]] -HasArgumentCompleter -DefaultValue "*"
            }

            It "has a parameter 'ValueOnly' of type [Switch]" {
                $command | Should -HaveParameter "ValueOnly" -Type [Switch]
            }

            It "has a parameter 'AsHashtable' of type[Switch]" {
                $command | Should -HaveParameter "AsHashtable" -Type [Switch]
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

            It "retrieves all keys" {
                $config = Get-Configuration -ErrorAction Stop

                $config | Should -HaveCount 4
                ($config | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Foo").Value | Should -BeOfType [String]
                ($config | Where-Object Name -eq "Bar").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Bar").Value | Should -BeOfType [Int]
                ($config | Where-Object Name -eq "Baz").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Baz").Value | Should -BeOfType [DateTime]
                ($config | Where-Object Name -eq "ServerList").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "ServerList").Value | Should -BeOfType [AtlassianPS.ServerData]
                ($config | Where-Object Name -eq "ServerList").Value.Session[0] | Should -BeNullOrEmpty
                ($config | Where-Object Name -eq "ServerList").Value.Session[1] | Should -Not -BeNullOrEmpty
            }

            It "filters the results by name of the configuration" {
                $config = Get-Configuration -Name "Foo" -ErrorAction Stop

                $config | Should -HaveCount 1
                ($config | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
            }

            It "filters the results by multiple names of configuration" {
                $config = Get-Configuration -Name "Foo", "Bar" -ErrorAction Stop

                $config | Should -HaveCount 2
                ($config | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Bar").Value | Should -Not -BeNullOrEmpty
            }

            It "allows for wildcards when filtering" {
                $config = Get-Configuration -Name "B*" -ErrorAction Stop

                $config | Should -HaveCount 2
                ($config | Where-Object Name -eq "Bar").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Baz").Value | Should -Not -BeNullOrEmpty
            }

            It "returns only the value when -ValueOnly is provided" {
                $config = Get-Configuration -Name "Bar" -ValueOnly -ErrorAction Stop

                $config | Should -HaveCount 1
                $config | Should -Not -BeNullOrEmpty
                $config | Should -BeOfType [Int]

                $config = Get-Configuration -Name "Foo" -ValueOnly -ErrorAction Stop
                $config | Should -HaveCount 1
                $config | Should -Not -BeNullOrEmpty
                $config | Should -BeOfType [String]
            }

            It "returns the configuration has Hashtable when -AsHashtable is provided" {
                $config = Get-Configuration -AsHashtable -ErrorAction Stop

                $config | Should -BeOfType [Hashtable]
                $config.Keys.Count | Should -Be 4
                $config["Foo"] | Should -Not -BeNullOrEmpty
                $config["Foo"] | Should -BeOfType [String]
                $config["Bar"] | Should -Not -BeNullOrEmpty
                $config["Bar"] | Should -BeOfType [Int]
                $config["Baz"] | Should -Not -BeNullOrEmpty
                $config["Baz"] | Should -BeOfType [DateTime]
                $config["ServerList"] | Should -Not -BeNullOrEmpty
                $config["ServerList"] | Should -BeOfType [AtlassianPS.ServerData]
                $config["ServerList"].Session[0] | Should -BeNullOrEmpty
                $config["ServerList"].Session[1] | Should -Not -BeNullOrEmpty
            }
        }
    }
}
