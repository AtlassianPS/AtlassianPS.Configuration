#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "Remove-ServerConfiguration" -Tag Unit {

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

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHManifestToTest
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

            It "has a [String[]] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should -Be "String[]"
            }

            It "has an alias -ServerName for -Name" {
                $command.Parameters["Name"].Aliases | Should -Contain "ServerName"
            }

            It "has an alias -Alias for -Name" {
                $command.Parameters["Name"].Aliases | Should -Contain "Alias"
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
                @(Get-ServerConfiguration).Count | Should -Be 2

                Remove-ServerConfiguration -Name "Google"

                @(Get-ServerConfiguration).Count | Should -Be 1
            }

            It "removes multiple entries of the servers" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                Remove-ServerConfiguration -Name "Google", "Google with Session"

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
                { Remove-ServerConfiguration -Name "Foo" -ErrorAction SilentlyContinue } | Should -Not -Throw
                { Remove-ServerConfiguration -Name "Foo" -ErrorAction Stop } | Should -Throw "No server 'foo' could be found."
            }
        }
    }
}
