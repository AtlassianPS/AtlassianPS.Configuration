#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

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
