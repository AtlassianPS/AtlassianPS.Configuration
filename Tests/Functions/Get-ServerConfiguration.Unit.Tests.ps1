#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force
}

Describe "Get-ServerConfiguration" -Tag Unit {

    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope "AtlassianPS.Configuration" {

        #region Mocking
        Mock Write-DebugMessage -ModuleName "AtlassianPS.Configuration" {}
        Mock Write-Verbose -ModuleName "AtlassianPS.Configuration" {}

        Mock Get-Configuration {
            $script:Configuration["ServerList"]
        }
        #endregion Mocking

        Context "Sanity checking" {

            BeforeAll {

                $script:command = Get-Command -Name Get-ServerConfiguration

            }

            It "has a mandatory parameter 'Name' of type [String[]] with ArgumentCompleter" {
                $command | Should -HaveParameter "Name" -Mandatory -Type [String[]] -HasArgumentCompleter
            }

            It "has a mandatory parameter 'Uri' of type [Uri] with ArgumentCompleter" {
                $command | Should -HaveParameter "Uri" -Mandatory -Type [Uri] -HasArgumentCompleter
            }

            It "has an alias '<alias>' for parameter '<parameter>'" -TestCases @(
                @{ParameterName = "Uri"; AliasName = "Address" }
                @{ParameterName = "Uri"; AliasName = "Url" }
                @{ParameterName = "Name"; AliasName = "ServerName" }
                @{ParameterName = "Name"; AliasName = "Alias" }
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

            It "retrieves all ServerData" {
                $config = Get-ServerConfiguration -ErrorAction SilentlyContinue

                $config | Should -HaveCount 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
                $config.Name | Should -Be @("Google", "Google with Session")
                $config.Uri | Should -Be @("https://google.com/", "https://google.com/")
                $config.Type | Should -Be @("Jira", "Jira")
                $config.Session.Count | Should -Be 2
                $config.Session[0] | Should -BeNullOrEmpty
                $config.Session[1] | Should -BeOfType [Microsoft.PowerShell.Commands.WebRequestSession]
            }

            It "filters the results by ServerName" {
                $config = Get-ServerConfiguration -Name "Google" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 1
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "filters the results by multiple ServerNames" {
                $config = Get-ServerConfiguration -Name "Google", "Google with Session" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "accepts names over the pipeline" {
                $config = "Google", "Google with Session" | Get-ServerConfiguration -ErrorAction SilentlyContinue

                $config | Should -HaveCount 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "accepts names over the pipeline from objects" {
                $objects = New-Object -TypeName PSCustomObject -Property @{
                    Name = "Google"
                }
                $config = $objects | Get-ServerConfiguration -ErrorAction SilentlyContinue

                $config | Should -HaveCount 1
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "does not allow for wildcards when filtering by ServerName" {
                $config = Get-ServerConfiguration -Name "Google*" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 0
            }

            It "is not case sensitive when filtering by ServerName" {
                $config = Get-ServerConfiguration -Name "google" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 1
            }

            It "filters the results by Uri" {
                $config = Get-ServerConfiguration -Uri "https://google.com" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 2
                $config | Should -BeOfType [AtlassianPS.ServerData]
            }

            It "is not case sensitive when filtering by Uri" {
                $config = Get-ServerConfiguration -Uri "https://GOOGLE.com" -ErrorAction SilentlyContinue

                $config | Should -HaveCount 2
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
