#requires -modules @{ ModuleName = "BuildHelpers"; ModuleVersion = "1.2" }
#requires -modules Pester

Describe "General project validation" -Tag Build {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot
    }
    AfterAll {
        Invoke-TestCleanup
    }
    AfterEach {
        Get-ChildItem TestDrive:\FunctionCalled* | Remove-Item
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "imports '$env:BHProjectName' cleanly" {
        Import-Module $env:BHManifestToTest

        $module = Get-Module $env:BHProjectName

        $module | Should BeOfType [PSModuleInfo]
    }

    It "has public functions" {
        Import-Module $env:BHManifestToTest

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "uses the correct root module" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName RootModule | Should -Be 'AtlassianPS.Configuration.psm1'
    }

    It "uses the correct guid" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName Guid | Should -Be 'f946e1f7-ed4f-43da-aa24-6d57a25117cb'
    }

    It "uses a valid version" {
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }

    It "requires Configuration" {
        # this workaround will be obsolete with
        # https://github.com/PoshCode/Configuration/pull/20
        $pureExpression = Get-Metadata -Path $env:BHManifestToTest -PropertyName RequiredModules -Passthru
        [Scriptblock]::Create($pureExpression.Extent.Text).Invoke() | Should -Contain 'Configuration'
    }

    It "loads Configuration into the global scope" {
        Remove-Module Configuration -Force -ErrorAction SilentlyContinue
        (Get-Module).Name | Should -Not -Contain Configuration

        Import-Module $env:BHManifestToTest -Force

        (Get-Module).Name | Should -Contain Configuration

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }

    It "loads saved configurations states on import" {
        Test-Path "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -Be $false

        New-Alias -Name Import-Configuration -Value LogCall -Scope Global
        Import-Module $env:BHManifestToTest
        Remove-Item alias:\Import-Configuration -ErrorAction SilentlyContinue

        "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -FileContentMatchExactly "Import-Configuration"
    }

    It "module is imported with default prefix" {
        $prefix = Get-Metadata -Path $env:BHManifestToTest -PropertyName DefaultCommandPrefix

        Import-Module $env:BHManifestToTest -Force -ErrorAction Stop
        (Get-Command -Module $env:BHProjectName).Name | ForEach-Object {
            $_ | Should -Match "\-$prefix"
        }
    }

    It "module is imported with custom prefix" {
        $prefix = "Test"

        Import-Module $env:BHManifestToTest -Prefix $prefix -Force -ErrorAction Stop
        (Get-Command -Module $env:BHProjectName).Name | ForEach-Object {
            $_ | Should -Match "\-$prefix"
        }
    }
}
