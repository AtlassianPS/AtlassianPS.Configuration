#requires -modules Pester

Describe "Help tests" -Tag Documentation {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    $DefaultParams = @(
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
        'WhatIf'
        'Confirm'
    )

    $commands = Get-Command -Module $env:BHProjectName -CommandType Cmdlet, Function, Workflow  # Not alias
    $classes = Get-ChildItem "$PSScriptRoot/../docs/en-US/classes"
    $enums = Get-ChildItem "$PSScriptRoot/../docs/en-US/enumerations"

    foreach ($command in $commands) {
        $commandName = $command.Name
        $markdownFile = Resolve-Path "$env:BHProjectPath/docs/en-US/commands/$commandName.md" -ErrorAction SilentlyContinue

        # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
        $help = Get-Help $commandName -ErrorAction Stop

        Context "Function $commandName's Help" {

            It "is described in a markdown file" {
                $markdownFile | Should -Not -BeNullOrEmpty
                Test-Path $markdownFile | Should -Be $true
            }

            It "does not have Comment-Based Help" {
                # We use .EXAMPLE, as we test this extensivly and it is never auto-generated
                $command.Definition | Should -Not -BeNullOrEmpty
                $Pattern = [regex]::Escape(".EXAMPLE")

                $command.Definition | Should -Not -Match "^\s*$Pattern"
            }

            It "has no platyPS template artifacts" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -Not -FileContentMatch '{{.*}}'
            }

            It "has a link to the 'Online Version'" {
                [Uri]$onlineLink = ($help.relatedLinks.navigationLink | Where-Object linkText -eq "Online Version:").Uri

                $onlineLink.Authority | Should -Be "atlassianps.org"
                $onlineLink.Scheme | Should -Be "https"
                $onlineLink.PathAndQuery | Should -Be "/docs/$env:BHProjectName/commands/$commandName/"
            }

            it "has a valid HelpUri" {
                $command.HelpUri | Should -Not -BeNullOrEmpty
                $Pattern = [regex]::Escape("https://atlassianps.org/docs/$env:BHProjectName/commands/$commandName")

                $command.HelpUri | Should -Match $Pattern
            }

            It "defines the frontmatter for the homepage" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -FileContentMatch "Module Name: $env:BHProjectName"
                $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                $markdownFile | Should -FileContentMatch "permalink: /docs/$env:BHProjectName/commands/$commandName/"
            }

            # Should be a synopsis for every function
            It "has a synopsis" {
                $help.Synopsis | Should -Not -BeNullOrEmpty
            }

            # Should be a description for every function
            It "has a description" {
                $help.Description.Text -join '' | Should -Not -BeNullOrEmpty
            }

            # Should be at least one example
            It "has examples" {
                ($help.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
            }

            # Should be at least one example description
            It "has desciptions for all examples" {
                foreach ($example in ($help.Examples.Example)) {
                    $example.remarks.Text | Should -Not -BeNullOrEmpty
                }
            }

            It "has at least as many examples as ParameterSets" {
                ($help.Examples.Example | Measure-Object).Count | Should -BeGreaterOrEqual $command.ParameterSets.Count
            }

            # It "does not define parameter position for functions with only one ParameterSet" {
            #     if ($command.ParameterSets.Count -eq 1) {
            #         $command.Parameters.Keys | Foreach-Object {
            #             $command.Parameters[$_].ParameterSets.Values.Position | Should -BeLessThan 0
            #         }
            #     }
            # }

            foreach ($parameterName in $command.Parameters.Keys) {
                $parameterCode = $command.Parameters[$parameterName]
                $parameterHelp = $help.Parameters.Parameter | Where-Object Name -EQ $parameterName

                if ($parameterName -notin $DefaultParams) {
                    It "has a description for parameter [-$parameterName] in $commandName" {
                        $parameterHelp.Description.Text | Should -Not -BeNullOrEmpty
                    }

                    It "has a mandatory flag for parameter [-$parameterName] in $commandName" {
                        $isMandatory = $parameterCode.ParameterSets.Values.IsMandatory -contains "True"

                        $parameterHelp.Required | Should -BeLike $isMandatory.ToString()
                    }

                    It "matches the type of the parameter in code and help" {
                        $codeType = $parameterCode.ParameterType.Name
                        if ($codeType -eq "Object") {
                            if (($parameterCode.Attributes) -and ($parameterCode.Attributes | Get-Member -Name PSTypeName)) {
                                $codeType = $parameterCode.Attributes[0].PSTypeName
                            }
                        }
                        # To avoid calling Trim method on a null object.
                        $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                        if ($helpType -eq "PSCustomObject") { $helpType = "PSObject" }

                        $helpType | Should -Be $codeType
                    }
                }

                It "does not have parameters that are not in the code" {
                    foreach ($helpParm in ($help.Parameters.Parameter.Name | Sort-Object -Unique)) {
                        $command.Parameters.Keys | Should -Contain $helpParm
                    }
                }
            }
        }
    }

    foreach ($className in $classes) {
        $markdownFile = Resolve-Path "$env:BHProjectPath/docs/en-US/classes/$className.md" -ErrorAction SilentlyContinue

        Context "Classes $className' Help" {

            It "is described in a markdown file" {
                $markdownFile | Should -Not -BeNullOrEmpty
                Test-Path $markdownFile | Should -Be $true
            }

            It "has no platyPS template artifacts" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -Not -FileContentMatch '{{.*}}'
            }

            It "defines the frontmatter for the homepage" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -FileContentMatch "Module Name: $env:BHProjectName"
                $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                $markdownFile | Should -FileContentMatch "permalink: /docs/$env:BHProjectName/classes/$commandName/"
            }
        }
    }

    Context "Missing classes" {
        It "has a documentation file for every class" {
            foreach ($class in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsClass)) {
                $classes.BaseName | Should -Contain $class.FullName
            }
        }
    }

    foreach ($enumName in $enums) {
        $markdownFile = Resolve-Path "$env:BHProjectPath/docs/en-US/enumerations/$enumName.md" -ErrorAction SilentlyContinue

        Context "Enumeration $enumName' Help" {

            It "is described in a markdown file" {
                $markdownFile | Should -Not -BeNullOrEmpty
                Test-Path $markdownFile | Should -Be $true
            }

            It "has no platyPS template artifacts" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -Not -FileContentMatch '{{.*}}'
            }

            It "defines the frontmatter for the homepage" {
                $markdownFile | Should -Not -BeNullOrEmpty
                $markdownFile | Should -FileContentMatch "Module Name: $env:BHProjectName"
                $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                $markdownFile | Should -FileContentMatch "permalink: /docs/$env:BHProjectName/enumerations/$commandName/"
            }
        }
    }

    Context "Missing classes" {
        It "has a documentation file for every class" {
            foreach ($enum in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsEnum)) {
                $enums.BaseName | Should -Contain $enum.FullName
            }
        }
    }
}
