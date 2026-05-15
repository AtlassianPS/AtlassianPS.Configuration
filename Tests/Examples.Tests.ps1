#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force
    $script:isBuildEnvironment = [string]::Equals($env:BHisBuild, 'True', [System.StringComparison]::OrdinalIgnoreCase)
    $script:moduleName = $env:BHProjectName
    $script:modulePrefix = (Import-PowerShellDataFile -Path $env:BHManifestToTest).DefaultCommandPrefix
    $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1" -File).BaseName
    $functions = foreach ($publicFunction in $publicFunctions) {
        $exportedCommandName = if ($script:modulePrefix) {
            $publicFunction -replace "-", "-$script:modulePrefix"
        }
        else {
            $publicFunction
        }

        Get-Command -Name $exportedCommandName -Module $script:moduleName -ErrorAction Stop
    }

    $script:exampleCases = @(
        foreach ($function in $functions) {
            $help = Get-Help $function.Name
            $exampleItems = @()
            if ($help -and ($help.PSObject.Properties.Name -contains 'Examples') -and $help.Examples) {
                $exampleItems = @($help.Examples.Example)
            }

            foreach ($example in $exampleItems) {
                $code = $example.Code
                if ([string]::IsNullOrWhiteSpace($code)) { continue }

                try {
                    [void][ScriptBlock]::Create($code)
                }
                catch {
                    continue
                }

                $title = ($example.Title -replace "-").Trim()
                if ([string]::IsNullOrWhiteSpace($title)) {
                    $title = "Example"
                }

                @{
                    CommandName = $function.Name
                    Title       = $title
                    Code        = $code
                }
            }
        }
    )
}

Describe "Validation of example codes in the documentation" -Tag Documentation, Build -Skip:(-not $script:isBuildEnvironment) {
    $moduleName = $script:moduleName

    BeforeAll {
    . "$PSScriptRoot/Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
    Import-Module $script:moduleToTest -Force

        # backup current configuration
        & (Get-Module $moduleName) {
            $script:previousConfig = $script:Configuration
            $script:Configuration = @{}
            $script:Configuration.Add("ServerList", [System.Collections.Generic.List[AtlassianPS.ServerData]]::new())
        }

        #region Mocks
        Mock Invoke-WebRequest { }
        Mock Invoke-RestMethod { }
        Mock Write-DebugMessage { } -ModuleName $moduleName
        Mock Write-Verbose { } -ModuleName $moduleName
        #endregion Mocks
    }

    AfterAll {
        #restore previous configuration
        & (Get-Module $moduleName) {
            $script:Configuration = $script:previousConfig
            Save-Configuration
        }

        Invoke-TestCleanup
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
