#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Resolve-FullPath" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "resolves a valid file path" {
            $filePath = Join-Path -Path $TestDrive -ChildPath "fullpath.txt"
            Set-Content -LiteralPath $filePath -Value "hello"

            Resolve-FullPath -Path $filePath | Should -Be $filePath
        }

        It "throws when file does not exist" {
            {
                Resolve-FullPath -Path (Join-Path -Path $TestDrive -ChildPath "missing.txt")
            } | Should -Throw -ExpectedMessage "*File not found*"
        }
    }
}

