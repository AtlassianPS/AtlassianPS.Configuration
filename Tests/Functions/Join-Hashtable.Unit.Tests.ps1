#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

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

        It "throws on duplicates when OnDuplicate is Error" {
            {
                @(
                    @{ a = 1 }
                    @{ a = 2 }
                ) | Join-Hashtable -OnDuplicate Error
            } | Should -Throw -ExpectedMessage "*Duplicate key 'a'*"
        }

        It "preserves key comparer behavior from first hashtable input" {
            $caseSensitive = [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
            $caseSensitive['Name'] = 'ValueA'

            $result = @(
                $caseSensitive
                @{ name = 'ValueB' }
            ) | Join-Hashtable

            $result.Count | Should -Be 2
            $result['Name'] | Should -Be 'ValueA'
            $result['name'] | Should -Be 'ValueB'
        }
    }
}

