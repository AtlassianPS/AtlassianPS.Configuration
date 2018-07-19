#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "Add-ServerConfiguration" -Tag Unit {

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

        Mock Get-ServerConfiguration -Module $env:BHProjectName {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Add-ServerConfiguration

            It "has a [String] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should -Be "String"
            }

            It "has an alias -ServerName for -Name" {
                $command.Parameters["Name"].Aliases | Should -Contain "ServerName"
            }

            It "has an alias -Alias for -Name" {
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

            It "adds a new server to the collection" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Add-ServerConfiguration -Name "New Server" -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
            }

            It "uses the [Uri]::Authority as default for server's name" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "atlassianps.org"

                Add-ServerConfiguration -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "atlassianps.org"
            }

            It "adds a new server entry from an existing over the pipeline" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Get-ServerConfiguration |
                    Where-Object Id -eq 1 |
                    Add-ServerConfiguration -Name "New Server"

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration)[0].Uri | Should -Be (Get-ServerConfiguration)[-1].Uri
                (Get-ServerConfiguration)[0].Type | Should -Be (Get-ServerConfiguration)[-1].Type
            }

            It "accepts the Uri over the pipeline" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                "https://atlassianps.org" | Add-ServerConfiguration -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "atlassianps.org"
                (Get-ServerConfiguration)[-1].Uri | Should -Be "https://atlassianps.org/"
                (Get-ServerConfiguration)[-1].Type | Should -Be "JIRA"
            }

            It "adds new server with the next highest index available" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Id | Should -Be @(1,2)

                1..8 | Foreach-Object {
                    Add-ServerConfiguration -Name "New Server $_" -Uri "https://atlassianps.org" -Type Jira
                }

                @(Get-ServerConfiguration).Count | Should -Be 10
                (Get-ServerConfiguration).Id | Should -Be @(1,2,3,4,5,6,7,8,9,10)
            }

            It "writes an error if the Name already exists in the collection" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Contain "Google"
                (Get-ServerConfiguration).Uri | Should -Not -Contain "https://atlassianps.org/"

                { Add-ServerConfiguration -Name "Google" -Uri "https://atlassianps.org/" -Type Jira -ErrorAction Stop } | Should -Throw "An entry with name [Google] already exists"
                { Add-ServerConfiguration -Name "Google" -Uri "https://atlassianps.org/" -Type Jira -ErrorAction SilentlyContinue } | Should -Not -Throw

                @(Get-ServerConfiguration).Count | Should -Be 2
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

            It "adds a server with the minimum set of parameters" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "atlassianps.org"

                Add-ServerConfiguration -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "atlassianps.org"
            }

            It "only allowed AtlassianPS server types" {
                @(Get-ServerConfiguration).Count | Should -Be 2

                { Add-ServerConfiguration -Name "Bitbucket" -Uri "https://atlassianps.org" -Type Bitbucket } | Should -Not -Throw
                { Add-ServerConfiguration -Name "Confluence" -Uri "https://atlassianps.org" -Type Confluence } | Should -Not -Throw
                { Add-ServerConfiguration -Name "Jira" -Uri "https://atlassianps.org" -Type Jira } | Should -Not -Throw
                # Hipchat is not yet supported
                { Add-ServerConfiguration -Name "Hipchat" -Uri "https://atlassianps.org" -Type Hipchat } | Should -Throw

                { Add-ServerConfiguration -Name "None" -Uri "https://atlassianps.org" -Type "" } | Should -Throw
                { Add-ServerConfiguration -Name "Github" -Uri "https://atlassianps.org" -Type Github } | Should -Throw

                @(Get-ServerConfiguration).Count | Should -Be 5
            }

            It "adds a server with the minimum set of parameters + Name" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                Add-ServerConfiguration -Name "New Server" -Uri "https://atlassianps.org" -Type Jira

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
            }

            It "adds a server with the minimum set of parameters + Name + Session" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                $webSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
                $webSession.UserAgent = "Test Value"
                Add-ServerConfiguration -Name "New Server" -Uri "https://atlassianps.org" -Type Jira -Session $webSession

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Session | Should -Not -BeNullOrEmpty
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Session.UserAgent | Should -Be "Test Value"
            }

            It "adds a server with the minimum set of parameters + Name + Session + Headers" {
                @(Get-ServerConfiguration).Count | Should -Be 2
                (Get-ServerConfiguration).Name | Should -Not -Contain "New Server"

                $webSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
                $webSession.UserAgent = "Test Value"
                Add-ServerConfiguration -Name "New Server" -Uri "https://atlassianps.org" -Type Jira -Session $webSession -Headers @{
                    Authorization = "Basic ABCDEF"
                }

                @(Get-ServerConfiguration).Count | Should -Be 3
                (Get-ServerConfiguration).Name | Should -Contain "New Server"
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Session | Should -Not -BeNullOrEmpty
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Session.UserAgent | Should -Be "Test Value"
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Headers | Should -BeOfType [Hashtable]
                (Get-ServerConfiguration | Where-Object Name -eq "New Server").Headers.Authorization | Should -Be "Basic ABCDEF"

            }
        }
    }
}
