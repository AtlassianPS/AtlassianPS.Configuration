#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
    Invoke-InitTest $PSScriptRoot
    Import-Module $env:BHManifestToTest -Force
}

Describe "Invoke-WebRequest" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope "AtlassianPS.Configuration" {

        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name Invoke-WebRequest
            }


        }

        Context "Behavior checking" { }
    }
}
