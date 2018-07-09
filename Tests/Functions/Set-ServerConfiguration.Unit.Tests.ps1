#requires -modules BuildHelpers
#requires -modules Pester

Describe "Set-ServerConfiguration" -Tag Unit {

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

        Mock Get-ServerConfiguration {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Set-ServerConfiguration

            It "has a [String] -ServerName parameter" {
                $command.Parameters.ContainsKey("ServerName")
                $command.Parameters["ServerName"].ParameterType | Should -Be "String"
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

            It "has a [AtlassianPS.ServerType] -Type parameter" {
                $command.Parameters.ContainsKey('Type')
                $command.Parameters["Type"].ParameterType | Should -Be "AtlassianPS.ServerType"
            }

            It "has a [Microsoft.PowerShell.Commands.WebRequestSession] -Session parameter" {
                $command.Parameters.ContainsKey('Session')
                $command.Parameters["Session"].ParameterType | Should -Be "Microsoft.PowerShell.Commands.WebRequestSession"
            }

            It "has a [Hashtable] -Headers parameter" {
                $command.Parameters.ContainsKey('Headers')
                $command.Parameters["Headers"].ParameterType | Should -Be "Hashtable"
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

            It "adds a new server if it didn't exist before" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Set-ServerConfiguration -Name "New Server" -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
            }

            It "overwrite an entry in case in existed before" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration | Where-Object Name -eq "Google").Uri | Should -Be "https://google.com/"

                Set-ServerConfiguration -Name "Google" -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration | Where-Object Name -eq "Google").Uri | Should -Be "https://atlassianps.org/"
            }

            It "only allowed AtlassianPS server types" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                { Set-ServerConfiguration -Name "Bitbucket" -Uri "https://atlassianps.org" -Type Bitbucket } | Should -Not -Throw
                { Set-ServerConfiguration -Name "Confluence" -Uri "https://atlassianps.org" -Type Confluence } | Should -Not -Throw
                { Set-ServerConfiguration -Name "Jira" -Uri "https://atlassianps.org" -Type Jira } | Should -Not -Throw
                # Hipchat is not yet supported
                { Set-ServerConfiguration -Name "Hipchat" -Uri "https://atlassianps.org" -Type Hipchat } | Should -Throw

                { Set-ServerConfiguration -Name "None" -Uri "https://atlassianps.org" -Type "" } | Should -Throw
                { Set-ServerConfiguration -Name "Github" -Uri "https://atlassianps.org" -Type Github } | Should -Throw

                @(Get-ServerConfiguration).Count | Should -Be 5
            }

            It "allows value to be passed over pipeline for a new entry" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration | Where-Object Name -eq "Google").Uri | Should -Be "https://google.com/"

                (Get-ServerConfiguration | Where-Object Name -eq "Google") | Set-ServerConfiguration -Uri "https://atlassianps.org"

                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration | Where-Object Name -eq "Google").Uri | Should -Be "https://atlassianps.org/"
            }

            It "allows value to be passed over pipeline for an existing entry" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration | Where-Object Name -eq "Google").Uri | Should -Be "https://google.com/"

                (Get-ServerConfiguration | Where-Object Name -eq "Google") | Set-ServerConfiguration -Name "NewName"

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "NewName"
                (Get-ServerConfiguration | Where-Object Name -eq "NewName").Uri | Should -Be "https://google.com/"
            }

            It "stores a WebSession to a server" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                $webSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
                $webSession.UserAgent = "Test Value"
                Set-ServerConfiguration -Name "New Entry" -Uri "https://atlassianps.org" -Type Jira -Session $webSession

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Entry"
                (Get-ServerConfiguration | Where-Object Name -eq "New Entry").Session | Should -Not -BeNullOrEmpty
                (Get-ServerConfiguration | Where-Object Name -eq "New Entry").Session.UserAgent | Should -Be "Test Value"
            }

            It "stores a hashtable for the Headers for a server" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                Set-ServerConfiguration -Name "New Entry" -Uri "https://atlassianps.org" -Type Jira -Headers @{
                    Authorization = "Basic ABCDEF"
                }

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Entry"
                (Get-ServerConfiguration | Where-Object Name -eq "New Entry").Headers | Should -BeOfType [Hashtable]
                (Get-ServerConfiguration | Where-Object Name -eq "New Entry").Headers.Authorization | Should -Be "Basic ABCDEF"
            }
        }
    }
}
