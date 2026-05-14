#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force
    $script:moduleName = $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix
    $script:defaultParams = @(
        'Verbose'
        'Debug'
        'ErrorAction'
        'WarningAction'
        'InformationAction'
        'ErrorVariable'
        'WarningVariable'
        'InformationVariable'
        'OutVariable'
        'OutBuffer'
        'PipelineVariable'
        'ProgressAction'
        'WhatIf'
        'Confirm'
    )

    $commandTypes = @('Cmdlet', 'Function')
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        $commandTypes += 'Workflow'
    }

    $script:abouts = @(
        Get-ChildItem "$env:BHProjectPath/docs/en-US/about*.md" -File |
            ForEach-Object {
                @{
                    BaseName = $_.BaseName
                    FullName = $_.FullName
                }
            }
    )
    $script:isRunningInReleaseFolder = if ($null -eq $env:BHisBuild -or $env:BHisBuild -eq '') {
        $false
    }
    else {
        [System.Convert]::ToBoolean($env:BHisBuild)
    }

    $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName
    $script:commands = @(
        foreach ($publicFunction in $publicFunctions) {
            $exportedCommandName = if ($script:modulePrefix) {
                $publicFunction -replace "-", "-$script:modulePrefix"
            }
            else {
                $publicFunction
            }

            $command = Get-Command -Name $exportedCommandName -Module $script:moduleName -CommandType $commandTypes -ErrorAction Stop
            @{
                Command           = $command
                CommandName       = $command.Name
                DocumentationName = $publicFunction
            }
        }
    )
}

Describe "Help tests" -Tag Documentation, Build {
    $moduleName = $script:moduleName

    BeforeAll {
    . "$PSScriptRoot/Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force
    }

    AfterAll {
        Invoke-TestCleanup
    }

    It "has an About help markdown for the module" {
        $abouts.BaseName | Should -Contain "about_$moduleName"
    }

    Context "About <_.BaseName>" -ForEach $abouts {
        BeforeAll {
            $script:markdownFile = $_.FullName
        }

        It "has no platyPS template artifacts" {
            $markdownFile | Should -Not -FileContentMatch '\{\{.*?\}\}'
        }

        It "defines frontmatter for homepage" {
            $markdownFile | Should -FileContentMatch "Module Name: $moduleName"
            $markdownFile | Should -FileContentMatchExactly "layout: documentation"
            $markdownFile | Should -FileContentMatch "permalink: /docs/$moduleName*"
        }
    }

    Describe "Public functions" {
        Context "Function <_.CommandName>" -ForEach $commands {
            BeforeAll {
                $script:command = $_.Command
                $script:documentationName = $_.DocumentationName
                $script:markdownFile = Resolve-Path "$env:BHProjectPath/docs/en-US/commands/$documentationName.md" -ErrorAction Stop
                $script:help = if ($isRunningInReleaseFolder) { Get-Help $command.Name -ErrorAction Stop }
            }

            It "is described in a markdown file" {
                $markdownFile | Should -Not -BeNullOrEmpty
                Test-Path $markdownFile | Should -Be $true
            }

            It "does not have comment-based help" {
                $command.Definition | Should -Not -BeNullOrEmpty
                $pattern = [regex]::Escape(".EXAMPLE")
                $command.Definition | Should -Not -Match "^\s*$pattern"
            }

            It "has no platyPS template artifacts" {
                $markdownFile | Should -Not -FileContentMatch '\{\{.*?\}\}'
            }

            It "defines frontmatter for homepage" {
                $markdownFile | Should -FileContentMatch "Module Name: $moduleName"
                $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                $markdownFile | Should -FileContentMatch "permalink: /docs/$moduleName/commands/$documentationName/"
            }

            Context "Compiled help for <_.CommandName>" -Skip:(-not $isRunningInReleaseFolder) {
                It "has synopsis and description" {
                    $help.Synopsis | Should -Not -BeNullOrEmpty
                    ($help.Description.Text -join '') | Should -Not -BeNullOrEmpty
                }

                It "has at least one example" {
                    ($help.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
                }

                It "does not expose undocumented parameters" {
                    $documented = @()
                    if ($help.Parameters | Get-Member -Name Parameter) {
                        $documented = @($help.Parameters.Parameter.Name)
                    }

                    foreach ($parameterName in $command.Parameters.Keys) {
                        if ($parameterName -in $defaultParams) { continue }

                        $paramAttr = $command.Parameters[$parameterName].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                        if ($paramAttr.DontShow -contains $true) { continue }

                        $documented | Should -Contain $parameterName
                    }
                }
            }
        }
    }
}
