#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
    $script:projectRoot = Resolve-ProjectRoot
    $script:moduleName = $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix

    ${/} = [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
    $script:isRunningInReleaseFolder = $moduleToTest -match "${/}Release${/}"
    if (-not $isRunningInReleaseFolder) {
        Write-Warning "Tests are being run outside of the 'Release' folder. Some tests may be skipped."
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

    $publicFunctions = @(
        Get-ChildItem "$env:BHModulePath/Public" -Recurse -File -Filter "*.ps1" |
            Sort-Object -Property FullName |
            Select-Object -ExpandProperty BaseName
    )

    $commandTypes = @('Cmdlet', 'Function')
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        $commandTypes += 'Workflow'
    }

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

    $script:DefaultParams = @(
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
}

Describe "Help tests" -Tag "Documentation", "Build" {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        $script:module = Get-Module $moduleName
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

        It "defines the frontmatter for the homepage" {
            $markdownFile | Should -FileContentMatch "Module Name: $moduleName"
            $markdownFile | Should -FileContentMatchExactly "layout: documentation"
            $markdownFile | Should -FileContentMatch "permalink: /docs/$moduleName*"
        }
    }

    Describe "Public Functions" {
        Context "Command <_.CommandName>" -ForEach $commands {
            BeforeDiscovery {
                if ($isRunningInReleaseFolder) {
                    $cmd = $_.Command
                    $isDontShow = {
                        param($name)
                        $paramAttr = $cmd.Parameters[$name].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                        return ($paramAttr.DontShow -contains $true)
                    }
                    $script:parameters = $cmd.Parameters.Keys | Where-Object { $_ -notin $DefaultParams -and -not (& $isDontShow $_) }
                }
                else {
                    $script:parameters = @()
                }
            }

            BeforeAll {
                $script:command = $_.Command
                $script:documentationName = $_.DocumentationName
                $script:markdownFile = Resolve-Path "$projectRoot/docs/en-US/commands/$documentationName.md" -ErrorAction Stop
                $script:help = if ($isRunningInReleaseFolder) { Get-Help $command.Name }
            }

            Context "Markdown file for <_.CommandName>" {
                It "is described in a markdown file" {
                    $markdownFile | Should -Not -BeNullOrEmpty
                    Test-Path $markdownFile | Should -Be $true
                }

                It "does not have Comment-Based Help" {
                    $command.Definition | Should -Not -BeNullOrEmpty
                    $pattern = [regex]::Escape(".EXAMPLE")
                    $command.Definition | Should -Not -Match "^\s*$pattern"
                }

                It "has no platyPS template artifacts" {
                    $markdownFile | Should -Not -BeNullOrEmpty
                    $markdownFile | Should -Not -FileContentMatch '\{\{.*?\}\}'
                }

                It "has a valid online version" {
                    $pattern = [regex]::Escape("https://atlassianps.org/docs/$moduleName/commands/$documentationName/")
                    $markdownFile | Should -FileContentMatch $pattern
                }

                It "defines the frontmatter for the homepage" {
                    $markdownFile | Should -Not -BeNullOrEmpty
                    $markdownFile | Should -FileContentMatch "Module Name: $moduleName"
                    $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                    $markdownFile | Should -FileContentMatch "permalink: /docs/$moduleName/commands/$documentationName/"
                }
            }

            Context "Help for <_.CommandName>" -Skip:(-not $isRunningInReleaseFolder) {
                It "has a synopsis" {
                    $help.Synopsis | Should -Not -BeNullOrEmpty
                }

                It "has a syntax" {
                    $help.syntax | Should -Not -BeNullOrEmpty
                }

                It "has a description" {
                    $help.Description.Text -join '' | Should -Not -BeNullOrEmpty
                }

                It "has examples" {
                    ($help.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
                }

                It "has desciptions for all examples" {
                    foreach ($example in ($help.Examples.Example)) {
                        $example.remarks.Text | Should -Not -BeNullOrEmpty
                    }
                }

                It "has at least as many examples as ParameterSets" {
                    ($help.Examples.Example | Measure-Object).Count | Should -BeGreaterOrEqual $command.ParameterSets.Count
                }

                It "has a link to the 'Online Version'" {
                    $onlineLinkValue = @(
                        $help.relatedLinks.navigationLink |
                            Where-Object { $_.linkText -match "^Online Version:?$" } |
                            ForEach-Object { $_.Uri } |
                            Where-Object { $_ } |
                            Select-Object -First 1
                    )

                    $onlineLinkValue | Should -Not -BeNullOrEmpty
                    [Uri]$onlineLink = $onlineLinkValue[0]

                    $onlineLink.Authority | Should -Be "atlassianps.org"
                    $onlineLink.Scheme | Should -Be "https"
                    $onlineLink.PathAndQuery | Should -Be "/docs/$moduleName/commands/$documentationName/"
                }

                It "has a valid HelpUri" -Skip { #TODO: Fix HelpUri generation
                    $command.HelpUri | Should -Not -BeNullOrEmpty
                    $pattern = [regex]::Escape("https://atlassianps.org/docs/$moduleName/commands/$documentationName")
                    $command.HelpUri | Should -Match $pattern
                }

                It "does not list Object[] / System.Object[] as a pipeline INPUT type" {
                    $inputTypeNodes = @()
                    if (
                        ($help.PSObject.Properties.Name -contains 'inputTypes') -and
                        $help.inputTypes -and
                        ($help.inputTypes.PSObject.Properties.Name -contains 'inputType')
                    ) {
                        $inputTypeNodes = @($help.inputTypes.inputType)
                    }

                    $inputNames = @($inputTypeNodes) | Where-Object { $_ } | ForEach-Object {
                        if ($_.type -and $_.type.name) { ($_.type.name -as [string]).Trim() }
                    }
                    foreach ($n in $inputNames) {
                        $n | Should -Not -Match '^(System\.)?Object\[\]$'
                    }
                }

                It "does not emit mangled input/output type names" {
                    $inputTypeNodes = @()
                    if (
                        ($help.PSObject.Properties.Name -contains 'inputTypes') -and
                        $help.inputTypes -and
                        ($help.inputTypes.PSObject.Properties.Name -contains 'inputType')
                    ) {
                        $inputTypeNodes = @($help.inputTypes.inputType)
                    }
                    $returnTypeNodes = @()
                    if (
                        ($help.PSObject.Properties.Name -contains 'returnValues') -and
                        $help.returnValues -and
                        ($help.returnValues.PSObject.Properties.Name -contains 'returnValue')
                    ) {
                        $returnTypeNodes = @($help.returnValues.returnValue)
                    }

                    $typeNames = @(
                        @($inputTypeNodes) +
                        @($returnTypeNodes)
                    ) | Where-Object { $_ } | ForEach-Object {
                        if ($_.type -and $_.type.name) { ($_.type.name -as [string]).Trim() }
                    }
                    foreach ($typeName in $typeNames) {
                        if ([string]::IsNullOrEmpty($typeName)) { continue }
                        $typeName | Should -Not -Match '^[\[\]]$'
                        $typeName.Length | Should -BeGreaterThan 1
                        $typeName | Should -Not -Match '^Markdig\.'
                        $typeName | Should -Not -Match '^<'
                    }
                }
            }

            Context "Parameter for <_.CommandName>" -Skip:(-not $isRunningInReleaseFolder) {
                Context "Parameter: <_>" -ForEach $parameters {
                    BeforeAll {
                        $script:parameterName = $_
                        $script:parameterCode = $command.Parameters[$parameterName]
                        $script:parameterHelp = @($help.Parameters.Parameter | Where-Object Name -eq $parameterName)
                    }

                    It "has a description" {
                        $helpDescriptions = @(
                            $parameterHelp |
                                ForEach-Object { @($_.Description.Text) } |
                                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
                        )
                        $helpDescriptions | Should -Not -BeNullOrEmpty
                    }

                    It "has a mandatory flag" {
                        $isMandatory = $parameterCode.ParameterSets.Values.IsMandatory -contains "True"
                        $command | Should -HaveParameter $parameterName -Mandatory:$isMandatory
                        $helpIsMandatory = @(
                            $parameterHelp |
                                ForEach-Object { (($_.Required -as [string]).Trim()) -match '^[Tt]rue$' }
                        ) -contains $true
                        $helpIsMandatory | Should -Be $isMandatory
                    }

                    It "matches the type of the parameter in code and help" {
                        $codeType = $parameterCode.ParameterType.Name
                        if ($codeType -eq "Object" -or $codeType -eq "Object[]") {
                            $psTypeAttr = $parameterCode.Attributes | Where-Object { $_ -is [System.Management.Automation.PSTypeNameAttribute] } | Select-Object -First 1
                            if ($psTypeAttr) {
                                $codeType = $psTypeAttr.PSTypeName
                                if ($parameterCode.ParameterType.IsArray -and $codeType -notmatch '\[\]$') {
                                    $codeType += '[]'
                                }
                            }
                        }

                        $helpTypes = @(
                            $parameterHelp |
                                ForEach-Object {
                                    if ($_.parameterValue) { ($_.parameterValue -as [string]).Trim() }
                                } |
                                Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                                ForEach-Object {
                                    if ($_ -eq "PSCustomObject") { "PSObject" }
                                    elseif ($_ -eq "Switch") { "SwitchParameter" }
                                    else { $_ }
                                } |
                                Sort-Object -Unique
                        )

                        $helpTypes | Should -Contain $codeType
                    }

                    It "preserves alias metadata in help" {
                        $codeAliases = @($parameterCode.Aliases | Sort-Object)
                        if ($codeAliases.Count -eq 0) { return }

                        $helpAliases = @(
                            $parameterHelp |
                                ForEach-Object { (($_.aliases -as [string]).Trim()) } |
                                Where-Object { $_ -and $_ -ne 'None' -and $_ -ne 'none' } |
                                ForEach-Object { $_ -split '[,\s]+' } |
                                Where-Object { $_ } |
                                Sort-Object -Unique
                        )

                        $helpAliases | Should -Be $codeAliases
                    }

                    It "preserves pipeline input flag in help" {
                        $byValue = $parameterCode.ParameterSets.Values.ValueFromPipeline -contains $true
                        $byProperty = $parameterCode.ParameterSets.Values.ValueFromPipelineByPropertyName -contains $true
                        $codeAcceptsPipeline = $byValue -or $byProperty

                        $helpAcceptsPipeline = @(
                            $parameterHelp |
                                ForEach-Object { (($_.pipelineInput -as [string]).Trim()) -match '^[Tt]rue' }
                        ) -contains $true

                        $helpAcceptsPipeline | Should -Be $codeAcceptsPipeline
                    }
                }

                It "does not have parameters that are not in the code" {
                    $parameter = @()
                    if ($help.Parameters | Get-Member -Name Parameter) {
                        $parameter = $help.Parameters.Parameter.Name | Sort-Object -Unique
                    }

                    foreach ($helpParm in $parameter) {
                        $command.Parameters.Keys | Should -Contain $helpParm
                    }
                }

                It "documents every public parameter exposed by the code" {
                    $documented = @()
                    if ($help.Parameters | Get-Member -Name Parameter) {
                        $documented = @($help.Parameters.Parameter.Name)
                    }

                    foreach ($paramName in $command.Parameters.Keys) {
                        if ($paramName -in $DefaultParams) { continue }
                        $paramAttr = $command.Parameters[$paramName].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                        if ($paramAttr.DontShow -contains $true) { continue }

                        $documented | Should -Contain $paramName
                    }
                }
            }
        }
    }
}
