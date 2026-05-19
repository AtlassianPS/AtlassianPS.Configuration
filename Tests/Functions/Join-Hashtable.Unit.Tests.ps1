#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Join-Hashtable" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "merges hashtables with last-value wins" {
            $result = @(
                @{ a = 1; b = 2 }
                $null
                @{ b = 3; c = 4 }
            ) | Join-Hashtable

            $result["a"] | Should -Be 1
            $result["b"] | Should -Be 3
            $result["c"] | Should -Be 4
        }
    }
}

