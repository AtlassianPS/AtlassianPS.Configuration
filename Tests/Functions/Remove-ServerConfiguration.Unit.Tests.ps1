#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Remove-ServerConfiguration" -Tag Unit {

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

        Mock Get-ServerConfiguration {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-ServerConfiguration

            It "has a mandatory parameter 'Name' of type [String[]] with ArgumentCompleter" {
                $command | Should -HaveParameter "Name" -Mandatory -Type [String[]] -HasArgumentCompleter
            }

            It "has an alias '<alias>' for parameter '<parameter>'" -TestCases @(
                @{ParameterName = "Name"; AliasName = "ServerName"}
                @{ParameterName = "Name"; AliasName = "Alias"}
            ) {
                param($ParameterName, $AliasName)
                $command.Parameters[$ParameterName].Aliases | Should -Contain $AliasName
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

            It "removes one entry of the servers" {
                Get-ServerConfiguration | Should -HaveCount 2

                Remove-ServerConfiguration -Name "Google"

                Get-ServerConfiguration | Should -HaveCount 1
            }

            It "removes multiple entries of the servers" {
                Get-ServerConfiguration | Should -HaveCount 2

                Remove-ServerConfiguration -Name "Google", "Google with Session"

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "accepts an object over the pipeline" {
                Get-ServerConfiguration | Should -HaveCount 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration).Name | Should -Contain "Google with Session"

                Get-ServerConfiguration | Remove-ServerConfiguration

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "accepts strings over the pipeline" {
                Get-ServerConfiguration | Should -HaveCount 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration).Name | Should -Contain "Google with Session"

                "Google", "Google with Session" | Remove-ServerConfiguration

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "writes an error when the server could not be removed" {
                { Remove-ServerConfiguration -Name "Foo" -ErrorAction SilentlyContinue } | Should -Not -Throw
                { Remove-ServerConfiguration -Name "Foo" -ErrorAction Stop } | Should -Throw "No server 'foo' could be found."
            }
        }
    }
}
