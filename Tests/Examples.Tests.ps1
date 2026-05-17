#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
    $script:moduleName = $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix

    $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName
    $script:commands = @(
        foreach ($publicFunction in $publicFunctions) {
            $exportedCommandName = if ($script:modulePrefix) {
                $publicFunction -replace "-", "-$script:modulePrefix"
            }
            else {
                $publicFunction
            }

            Get-Command -Name $exportedCommandName -Module $script:moduleName -ErrorAction Stop
        }
    )

    $normalizeExampleTitle = {
        param([string]$Title)

        if ([string]::IsNullOrWhiteSpace($Title)) {
            return "Example"
        }

        return ($Title -replace '^-+', '').Trim()
    }

    $exampleCases = [System.Collections.Generic.List[hashtable]]::new()
    $exampleParseErrors = [System.Collections.Generic.List[hashtable]]::new()

    foreach ($command in $commands) {
        $help = Get-Help $command.Name -ErrorAction SilentlyContinue
        if (-not $help -or -not $help.Examples) { continue }

        foreach ($example in @($help.Examples.Example)) {
            $code = $example.Code -as [string]
            if ([string]::IsNullOrWhiteSpace($code)) { continue }

            $title = & $normalizeExampleTitle ($example.Title -as [string])

            try {
                [void][ScriptBlock]::Create($code)
            }
            catch {
                $exampleParseErrors.Add(@{
                        CommandName = $command.Name
                        Title       = $title
                        Error       = $_.Exception.Message
                    })
                continue
            }

            $exampleCases.Add(@{
                    CommandName = $command.Name
                    Title       = $title
                    Code        = $code
                })
        }
    }

    $script:exampleCases = @($exampleCases)
    $script:exampleParseErrors = @($exampleParseErrors)
}

Describe "Validation of example codes in the documentation" -Tag Documentation, Build {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        $script:moduleName = $env:BHProjectName
        $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix
        Import-Module $script:moduleToTest -Force -ErrorAction Stop
        $script:module = Get-Module $script:moduleName

        & $script:module {
            $script:previousConfig = $script:Configuration
            $script:Configuration = @{
                ServerList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
            }
        }

        Mock Invoke-WebRequest { } -ModuleName $script:moduleName
        Mock Invoke-RestMethod { } -ModuleName $script:moduleName
        Mock Write-DebugMessage { } -ModuleName $script:moduleName
        Mock Write-Verbose { } -ModuleName $script:moduleName
    }

    AfterAll {
        & $script:module {
            $script:Configuration = $script:previousConfig
            Save-Configuration
        }
    }

    It "has no syntactically invalid examples" {
        if ($exampleParseErrors.Count -gt 0) {
            $details = $exampleParseErrors |
                ForEach-Object { "$($_.CommandName) [$($_.Title)]: $($_.Error)" } |
                Sort-Object
            throw "The following examples are not valid PowerShell code:`n  $($details -join "`n  ")"
        }
    }

    It "has executable examples for every public command" {
        $commandsWithExamples = @($exampleCases | ForEach-Object CommandName | Sort-Object -Unique)
        $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName
        $expectedCommands = @(
            foreach ($publicFunction in $publicFunctions) {
                if ($script:modulePrefix) {
                    $publicFunction -replace "-", "-$script:modulePrefix"
                }
                else {
                    $publicFunction
                }
            }
        )

        foreach ($commandName in $expectedCommands) {
            $commandsWithExamples | Should -Contain $commandName
        }
    }

    Context "Example <_.Title> for <_.CommandName>" -ForEach $exampleCases {
        It "runs without throwing" {
            {
                $originalErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = "Stop"
                try {
                    $scriptBlock = [ScriptBlock]::Create($_.Code)
                    & $scriptBlock
                }
                finally {
                    $ErrorActionPreference = $originalErrorActionPreference
                }
            } | Should -Not -Throw
        }
    }
}
