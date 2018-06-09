#requires -modules Pester

Describe "Remove-ServerConfiguration" -Tag Unit {

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

    InModuleScope $env:BHProjectName {

        #region Mocking
        Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
        Mock Write-Verbose -ModuleName $env:BHProjectName {}

        Mock Get-ServerConfiguration {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-ServerConfiguration

            It "has a [String[]] -ServerName parameter" {
                $command.Parameters.ContainsKey("ServerName")
                $command.Parameters["ServerName"].ParameterType | Should -Be "String[]"
            }

            It "has an alias -Name for -Servername" {
                $command.Parameters["ServerName"].Aliases | Should -Contain "Name"
            }

            It "has an alias -Alias for -Servername" {
                $command.Parameters["ServerName"].Aliases | Should -Contain "Alias"
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
                            Name = "Google"
                            Uri  = "https://google.com"
                            Type = "Jira"
                        }
                        [AtlassianPS.ServerData]@{
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
                @(Get-ServerConfiguration).Count | Should -Be 2

                Remove-ServerConfiguration -ServerName "Google"

                @(Get-ServerConfiguration).Count | Should -Be 1
            }

            It "removes multiple entries of the servers" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                Remove-ServerConfiguration -ServerName "Google", "Google with Session"

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "accepts an object over the pipeline" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration).Name | Should -Contain "Google with Session"

                Get-ServerConfiguration | Remove-ServerConfiguration

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "accepts strings over the pipeline" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration).Name | Should -Contain "Google with Session"

                "Google", "Google with Session" | Remove-ServerConfiguration

                Get-ServerConfiguration | Should -BeNullOrEmpty
            }

            It "writes an error when the server could not be removed" {
                { Remove-ServerConfiguration -ServerName "Foo" -ErrorAction SilentlyContinue } | Should -Not -Throw
                { Remove-ServerConfiguration -ServerName "Foo" -ErrorAction Stop } | Should -Throw "No server 'foo' could be found."
            }
        }
    }
}
