#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Validation of example codes in the documentation" -Tag Integration, NotImplemented {

    BeforeAll {
    . "$PSScriptRoot/Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
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
