#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }


Describe "Remove-Configuration" -Tag Unit {

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
            $tempConfig.Keys |
                ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_
                    Value = $tempConfig[$_]
                }
            }
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-Configuration

            It "has a [String[]] -Name parameter" {
                $command.Parameters.ContainsKey("Name")
                $command.Parameters["Name"].ParameterType | Should Be "String[]"
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

            It "removes one entry of the configuration" {
                @(Get-Configuration).Count | Should Be 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "Foo"

                @(Get-Configuration).Count | Should Be 3
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
            }

            It "removes multiple entries at once" {
                @(Get-Configuration).Count | Should Be 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Baz" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "Foo", "Bar"

                @(Get-Configuration).Count | Should Be 2
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Baz" | Should -Not -BeNullOrEmpty
            }

            It "accepts an object over the pipeline" {
                @(Get-Configuration).Count | Should Be 4

                Get-Configuration | Remove-Configuration

                @(Get-Configuration).Count | Should Be 0
            }

            It "accepts strings over the pipeline" {
                @(Get-Configuration).Count | Should Be 4

                "Foo", "Bar" | Remove-Configuration

                @(Get-Configuration).Count | Should Be 2
            }

            It "is not case sensitive" {
                @(Get-Configuration).Count | Should Be 4
                Get-Configuration | Where-Object Name -eq "Foo" | Should -Not -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty

                Remove-Configuration -Name "foo"

                @(Get-Configuration).Count | Should Be 3
                Get-Configuration | Where-Object Name -eq "Foo" | Should -BeNullOrEmpty
                Get-Configuration | Where-Object Name -eq "Bar" | Should -Not -BeNullOrEmpty
            }
        }
    }
}
