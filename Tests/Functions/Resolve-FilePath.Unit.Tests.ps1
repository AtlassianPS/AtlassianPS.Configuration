#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe "Resolve-FilePath" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "resolves relative paths to full paths" {
            $folder = Join-Path -Path $TestDrive -ChildPath "files"
            $filePath = Join-Path -Path $folder -ChildPath "sample.txt"
            $null = New-Item -Path $folder -ItemType Directory -Force
            Set-Content -LiteralPath $filePath -Value "hello"

            Push-Location -Path $folder
            try {
                Resolve-FilePath -Path ".\sample.txt" | Should -Be $filePath
            }
            finally {
                Pop-Location
            }
        }
    }
}

