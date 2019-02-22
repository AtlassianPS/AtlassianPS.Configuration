#requires -modules BuildHelpers
#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Documentation, Build {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest

        # backup current configuration
        & (Get-Module $env:BHProjectName) {
            $script:previousConfig = $script:Configuration
            $script:Configuration = @{}
            $script:Configuration.Add("ServerList", [System.Collections.Generic.List[AtlassianPS.ServerData]]::new())
        }
    }
    AfterAll {
        #restore previous configuration
        & (Get-Module $env:BHProjectName) {
            $script:Configuration = $script:previousConfig
            Save-Configuration
        }

        Invoke-TestCleanup
    }

    Assert-True { $env:BHisBuild } "Examples can only be tested in the build environment. Please run `Invoke-Build -Task Build`."

    #region Mocks
    Mock Invoke-WebRequest { }
    Mock Invoke-RestMethod { }
    Mock Write-DebugMessage { } -ModuleName $env:BHProjectName
    Mock Write-Verbose { } -ModuleName $env:BHProjectName
    #endregion Mocks

    foreach ($function in (Get-Command -Module $env:BHProjectName)) {
        Context "Examples of $($function.Name)" {
            $originalErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = "Stop"

            $help = Get-Help $function.Name

            foreach ($example in $help.examples.example) {
                $exampleName = ($example.title -replace "-").trim()

                It "has a working example: $exampleName" {
                    {
                        $scriptBlock = [Scriptblock]::Create($example.code)

                        & $scriptBlock
                    } | Should -Not -Throw
                }
            }

            $ErrorActionPreference = $originalErrorActionPreference
        }
    }
}
