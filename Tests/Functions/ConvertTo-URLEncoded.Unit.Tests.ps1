#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

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

        It "supports pipeline input and round-trips with decoder" {
            $encoded = @("first value", "second+value") | ConvertTo-URLEncoded
            $decoded = $encoded | ConvertFrom-URLEncoded

            $decoded[0] | Should -Be "first value"
            $decoded[1] | Should -Be "second+value"
        }
    }
}

