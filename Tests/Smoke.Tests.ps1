#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Smoke validation" -Tag Integration, Smoke {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        $script:manifestData = Import-PowerShellDataFile -Path $env:BHManifestToTest
    }

    It "imports module cleanly" {
        { Import-Module $script:moduleToTest -Force -ErrorAction Stop } | Should -Not -Throw
    }

    It "exposes the default-prefix Get-Configuration command" {
        Import-Module $script:moduleToTest -Force -ErrorAction Stop

        $expectedCommand = "Get-{0}Configuration" -f $script:manifestData.DefaultCommandPrefix
        (Get-Command -Name $expectedCommand -ErrorAction Stop).Name | Should -Be $expectedCommand
    }
}
