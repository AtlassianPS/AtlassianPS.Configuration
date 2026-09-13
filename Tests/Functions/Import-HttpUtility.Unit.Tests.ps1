#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe "Import-HttpUtility" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "loads System.Web.HttpUtility" {
            Import-HttpUtility

            'System.Web.HttpUtility' -as [Type] | Should -Not -BeNullOrEmpty
        }
    }
}
