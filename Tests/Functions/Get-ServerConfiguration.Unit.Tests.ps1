#requires -modules BuildHelpers
#requires -modules Pester

Describe "Get-ServerConfiguration" -Tag Unit {

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

        Import-Module "$env:BHProjectPath/Tools/build.psm1"

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

        Mock Get-Configuration {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Get-ServerConfiguration

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

            It "has a [Uri] -Uri parameter" {
                $command.Parameters.ContainsKey('Uri')
                $command.Parameters["Uri"].ParameterType | Should -Be "Uri"
            }

            It "has an alias -Address for -Uri" {
                $command.Parameters["Uri"].Aliases | Should -Contain "Address"
            }

            It "has an alias Url for -Uri" {
                $command.Parameters["Uri"].Aliases | Should -Contain "Url"
            }

        }

        Context "Behavior checking" {

            #region Arrange
            BeforeEach {
                $script:Configuration = @{
                    Foo = "lorem ipsum"
                    Bar = 42
                    Baz = (Get-Date)
                    ServerList = @(
                        [AtlassianPS.ServerData]@{
                            Name = "Google"
                            Uri = "https://google.com"
                            Type = "Jira"
                        }
                        [AtlassianPS.ServerData]@{
                            Name = "Google with Session"
                            Uri = "https://google.com"
                            Type = "Jira"
                            Session = (New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession)
                        }
                    )
                }
            }
            #endregion Arrange

            It "retrieves all ServerData" {
                $config = Get-ServerConfiguration -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
                $config.Name | Should -Be @("Google", "Google with Session")
                $config.Uri | Should -Be @("https://google.com/", "https://google.com/")
                $config.Type | Should -Be @("Jira", "Jira")
                $config.Session.Count | Should -Be 2
                $config.Session[0] | Should -BeNullOrEmpty
                $config.Session[1] | Should -BeOfType [Microsoft.PowerShell.Commands.WebRequestSession]
            }

            It "filters the results by ServerName" {
                $config = Get-ServerConfiguration -ServerName "Google" -ErrorAction Stop

                @($config).Count | Should -Be 1
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "filters the results by multiple ServerNames" {
                $config = Get-ServerConfiguration -ServerName "Google", "Google with Session" -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "accepts names over the pipeline" {
                $config = "Google", "Google with Session" | Get-ServerConfiguration -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "accepts names over the pipeline from objects" {
                $objects = New-Object -TypeName PSCustomObject -Property @{
                    Name = "Google"
                }
                $config = $objects | Get-ServerConfiguration -ErrorAction Stop

                @($config).Count | Should -Be 1
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "does not allow for wildcards when filtering by ServerName" {
                $config = Get-ServerConfiguration -ServerName "Google*" -ErrorAction Stop

                @($config).Count | Should -Be 0
            }

            It "is not case sensitive when filtering by ServerName" {
                $config = Get-ServerConfiguration -ServerName "google" -ErrorAction Stop

                @($config).Count | Should -Be 1
            }

            It "filters the results by Uri" {
                $config = Get-ServerConfiguration -Uri "https://google.com" -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "is not case sensitive when filtering by Uri" {
                $config = Get-ServerConfiguration -Uri "https://GOOGLE.com" -ErrorAction Stop

                @($config).Count | Should -Be 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }
            It "allows for wildcards when filtering by Uri - but not any wildcard" {
                # As -Uri parses the a string input, the behavior with wildcards is wonky
                { [Uri]"https://google*" } | Should -Throw
                { [Uri]"https://g*.com/" } | Should -Throw

                [Uri]"https://google.com/*" | Should -Not -BeNullOrEmpty
                [Uri]"http*://google.*" | Should -Not -BeNullOrEmpty
                [Uri]"http*://g*.com/" | Should -Not -BeNullOrEmpty
                [Uri]"http*://google.com/" | Should -Not -BeNullOrEmpty

                [Uri]"https://goo.com/" | Should -Not -BeNullOrEmpty
            }
        }
    }
}
