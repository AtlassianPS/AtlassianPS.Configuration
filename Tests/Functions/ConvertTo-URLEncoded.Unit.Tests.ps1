#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ConvertTo-URLEncoded" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "encodes plain text" {
            ConvertTo-URLEncoded -InputString "hello world+value" | Should -Not -Be "hello world+value"
        }
    }
}

