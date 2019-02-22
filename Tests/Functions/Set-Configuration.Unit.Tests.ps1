#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Set-Configuration" -Tag Unit {

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

        Mock Get-Configuration {
            $tempConfig = $script:Configuration.Clone()
            $return = $tempConfig.Keys |
                ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_
                    Value = $tempConfig[$_]
                }
            }
            if ($Name) {
                $return = $return | Where-Object Name -eq $Name
            }
            if ($ValueOnly) {
                $return = $return.Value
            }
            $return
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Set-Configuration

            It "has a mandatory parameter 'Name' of type [String] with ArgumentCompleter" {
                $command | Should -HaveParameter "Name" -Mandatory -Type [String] -HasArgumentCompleter
            }

            It "has a parameter 'Value' of type [Object]" {
                $command | Should -HaveParameter "Value" -Type [System.Object]
            }

            It "has a parameter 'Append' of type [Switch]" {
                $command | Should -HaveParameter "Append" -Type [Switch]
            }

            It "has a parameter 'Passthru' of type [Switch]" {
                $command | Should -HaveParameter 'Passthru' -Type [Switch]
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

            It "adds a new entry if it didn't exist before" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "StringValue").Value | Should -BeNullOrEmpty

                Set-Configuration -Name "StringValue" -Value "Lorem Ipsum"

                Get-Configuration | Should -HaveCount 5
                (Get-Configuration | Where-Object Name -eq "StringValue").Value | Should -Not -BeNullOrEmpty
            }

            It "overwrite an entry in case in existed before" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty

                Set-Configuration -Name "Foo" -Value "New Value"

                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
            }

            It "appends a value to an entry" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Be 42

                Set-Configuration -Name "Bar" -Value 100 -Append

                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Contain 42
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Contain 100
            }

            It "allows value to be passed over pipeline for a new entry" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "NewKey").Value | Should -BeNullOrEmpty
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "lorem ipsum"

                Get-Configuration -Name "Foo" | Set-Configuration -Name "NewKey"

                Get-Configuration | Should -HaveCount 5
                (Get-Configuration | Where-Object Name -eq "NewKey").Value | Should -Be "lorem ipsum"
            }

            It "allows value to be passed over pipeline for an existing entry" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "lorem ipsum"

                Get-Configuration -Name "Foo" | Set-Configuration -Value "New Value"

                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "New Value"
            }

            It "allows to set the value to null" {
                Get-Configuration | Should -HaveCount 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "lorem ipsum"
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Be 42

                Set-Configuration -Name "Foo" -Value ""
                Set-Configuration -Name "Bar" -Value $null

                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -BeNullOrEmpty
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -BeNullOrEmpty
            }
        }
    }
}
