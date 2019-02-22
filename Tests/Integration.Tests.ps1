#requires -modules BuildHelpers
#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Integration, NotImplemented {

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

    #region Mocks
    #endregion Mocks

    Context "Importing of module" {}
}
