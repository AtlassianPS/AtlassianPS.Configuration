#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "Get-Configuration" -Tag Unit {

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
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Get-Configuration

            It "has a [String[]] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should -Be "String[]"
            }

            It "has a [Switch] -ValueOnly parameter" {
                $command.Parameters.ContainsKey("ValueOnly")
                $command.Parameters["ValueOnly"].ParameterType | Should -Be "Switch"
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

                @($config).Count | Should -Be 4
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

                @($config).Count | Should -Be 1
                ($config | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
            }

            It "filters the results by multiple names of configuration" {
                $config = Get-Configuration -Name "Foo", "Bar" -ErrorAction Stop

                @($config).Count | Should -Be 2
                ($config | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Bar").Value | Should -Not -BeNullOrEmpty
            }

            It "allows for wildcards when filtering" {
                $config = Get-Configuration -Name "B*" -ErrorAction Stop

                @($config).Count | Should -Be 2
                ($config | Where-Object Name -eq "Bar").Value | Should -Not -BeNullOrEmpty
                ($config | Where-Object Name -eq "Baz").Value | Should -Not -BeNullOrEmpty
            }

            It "returns only the value when -ValueOnly is provided" {
                $config = Get-Configuration -Name "Foo", "Bar" -ValueOnly -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config[0] | Should -Not -BeNullOrEmpty
                $config[0] | Should -BeOfType [String]
                $config[1] | Should -Not -BeNullOrEmpty
                $config[1] | Should -BeOfType [Int]
            }
        }
    }
}
