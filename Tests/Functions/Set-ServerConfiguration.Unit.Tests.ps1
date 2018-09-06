#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


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

        Mock Get-ServerConfiguration -Module $env:BHProjectName {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Set-ServerConfiguration

            It "has a [String] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should -Be "String"
            }

            It "has an alias -ServerName for -Name" {
                $command.Parameters["Name"].Aliases | Should -Contain "ServerName"
            }

            It "has an alias -Alias for -name" {
                $command.Parameters["Name"].Aliases | Should -Contain "Alias"
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

            It "uses -Id to identify the entry to change" {
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Set-ServerConfiguration -Id 1 -Name "New Server"

                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration | Where-Object Id -eq 1).Name | Should -Be "New Server"
            }

            It "accepts the Id over the pipeline" {
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                1 | Set-ServerConfiguration -Name "New Server"

                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration | Where-Object Id -eq 1).Name | Should -Be "New Server"
            }

            It "accepts the Id over the pipeline as a property" {
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Get-ServerConfiguration |
                    Where-Object Id -eq 1 |
                    Set-ServerConfiguration -Name "New Server"

                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration | Where-Object Id -eq 1).Name | Should -Be "New Server"
            }

            It "does not change the number of entries" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                Set-ServerConfiguration -Id 1 -Name "New Server"
                1 | Set-ServerConfiguration -Name "New Server"
                Get-ServerConfiguration |
                    Where-Object Id -eq 1 |
                    Set-ServerConfiguration -Name "New Server"

                @(Get-ServerConfiguration).Count | Should -Be 2
            }

            It "writes an error if the index does not exist" {
                { Set-ServerConfiguration -Id 1 -Name "New Server" -ErrorAction Stop } | Should -Not -Throw
                { Set-ServerConfiguration -Id 2 -Name "New Server" -ErrorAction Stop } | Should -Not -Throw
                { Set-ServerConfiguration -Id 3 -Name "New Server" -ErrorAction Stop } | Should -Throw "No entry could be found at index 3"
                { Set-ServerConfiguration -Id 3 -Name "New Server" -ErrorAction SilentlyContinue } | Should -Not -Throw
            }
        }

        Context "Parameter checking" {

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

            It "can change the Name" {
                (Get-ServerConfiguration | Where Id -eq 1).Name | Should -Be "Google"

                Set-ServerConfiguration -Id 1 -Name "https://atlassianps.org"

                (Get-ServerConfiguration | Where Id -eq 1).Name | Should -Be "https://atlassianps.org"
            }

            It "can change the Uri" {
                (Get-ServerConfiguration | Where Id -eq 1).Uri | Should -Be "https://google.com/"

                Set-ServerConfiguration -Id 1 -Uri "https://atlassian.net"

                (Get-ServerConfiguration | Where Id -eq 1).Uri | Should -Be "https://atlassian.net/"
            }

            It "can change the Type" {
                (Get-ServerConfiguration | Where Id -eq 1).Type | Should -Be "Jira"

                Set-ServerConfiguration -Id 1 -Type Bitbucket

                (Get-ServerConfiguration | Where Id -eq 1).Type | Should -Be "Bitbucket"
            }

            It "only allowed AtlassianPS server types" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                { Set-ServerConfiguration -Id 1 -Name "Bitbucket" -Uri "https://atlassianps.org" -Type Bitbucket } | Should -Not -Throw
                { Set-ServerConfiguration -Id 1 -Name "Confluence" -Uri "https://atlassianps.org" -Type Confluence } | Should -Not -Throw
                { Set-ServerConfiguration -Id 1 -Name "Jira" -Uri "https://atlassianps.org" -Type Jira } | Should -Not -Throw
                # Hipchat is not yet supported
                { Set-ServerConfiguration -Id 1 -Name "Hipchat" -Uri "https://atlassianps.org" -Type Hipchat } | Should -Throw

                { Set-ServerConfiguration -Id 1 -Name "None" -Uri "https://atlassianps.org" -Type "" } | Should -Throw
                { Set-ServerConfiguration -Id 1 -Name "Github" -Uri "https://atlassianps.org" -Type Github } | Should -Throw

                @(Get-ServerConfiguration).Count | Should -Be 2
            }

            It "can change the WebSession" {
                (Get-ServerConfiguration | Where Id -eq 1).Session | Should -BeNullOrEmpty

                $webSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
                $webSession.UserAgent = "Test Value"
                Set-ServerConfiguration -Id 1 -Session $webSession

                (Get-ServerConfiguration | Where Id -eq 1).Session | Should -Not -BeNullOrEmpty
                (Get-ServerConfiguration | Where Id -eq 1).Session.UserAgent | Should -Be "Test Value"
            }

            It "can change the Headers" {
                (Get-ServerConfiguration | Where Id -eq 1).Headers | Should -BeNullOrEmpty

                Set-ServerConfiguration -Id 1 -Headers @{ Authorization = "Basic ABCDEF" }

                (Get-ServerConfiguration | Where Id -eq 1).Headers | Should -BeOfType [Hashtable]
                (Get-ServerConfiguration | Where Id -eq 1).Headers.Authorization | Should -Be "Basic ABCDEF"
            }
        }
    }
}
