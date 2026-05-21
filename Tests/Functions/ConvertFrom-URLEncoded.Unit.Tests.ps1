#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ConvertFrom-URLEncoded" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "decodes encoded text" {
            ConvertFrom-URLEncoded -InputString "hello+world%2Bvalue" | Should -Be "hello world+value"
        }

        It "decodes pipeline arrays" {
            $decoded = @("hello+world", "one%2Btwo") | ConvertFrom-URLEncoded

            $decoded | Should -HaveCount 2
            $decoded[0] | Should -Be "hello world"
            $decoded[1] | Should -Be "one+two"
        }
    }
}

