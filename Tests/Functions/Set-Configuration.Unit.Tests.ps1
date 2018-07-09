#requires -modules BuildHelpers
#requires -modules Pester

Describe "Set-Configuration" -Tag Unit {

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
            $tempConfig = $script:Configuration.Clone()
            $return = $tempConfig.Keys |
                ForEach-Object {
                [PSCustomObject]@{
                    Name = $_
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

            It "has a [String] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should -Be "String"
            }

            It "has a [Object] -Value parameter" {
                $command.Parameters.ContainsKey("Value")
                $command.Parameters["Value"].ParameterType | Should -Be "System.Object"
            }

            It "has a [Switch] -Append parameter" {
                $command.Parameters.ContainsKey("Append")
                $command.Parameters["Append"].ParameterType | Should -Be "Switch"
            }

            It "has a [Switch] -Passthru parameter" {
                $command.Parameters.ContainsKey("Passthru")
                $command.Parameters["Passthru"].ParameterType | Should -Be "Switch"
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

            It "adds a new entry if it didn't exist before" {
                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "StringValue").Value | Should -BeNullOrEmpty

                Set-Configuration -Name "StringValue" -Value "Lorem Ipsum"

                @(Get-Configuration).Count | Should -Be 5
                (Get-Configuration | Where-Object Name -eq "StringValue").Value | Should -Not -BeNullOrEmpty
            }

            It "overwrite an entry in case in existed before" {
                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty

                Set-Configuration -Name "Foo" -Value "New Value"

                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Not -BeNullOrEmpty
            }

            It "appends a value to an entry" {
                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Be 42

                Set-Configuration -Name "Bar" -Value 100 -Append

                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Contain 42
                (Get-Configuration | Where-Object Name -eq "Bar").Value | Should -Contain 100
            }

            It "allows value to be passed over pipeline for a new entry" {
                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "NewKey").Value | Should -BeNullOrEmpty
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "lorem ipsum"

                Get-Configuration -Name "Foo" | Set-Configuration -Name "NewKey"

                @(Get-Configuration).Count | Should -Be 5
                (Get-Configuration | Where-Object Name -eq "NewKey").Value | Should -Be "lorem ipsum"
            }

            It "allows value to be passed over pipeline for an existing entry" {
                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "lorem ipsum"

                Get-Configuration -Name "Foo" | Set-Configuration -Value "New Value"

                @(Get-Configuration).Count | Should -Be 4
                (Get-Configuration | Where-Object Name -eq "Foo").Value | Should -Be "New Value"
            }

            It "allows to set the value to null" {
                @(Get-Configuration).Count | Should -Be 4
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
