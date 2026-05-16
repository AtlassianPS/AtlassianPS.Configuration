#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "General project validation" -Tag Build {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        $script:manifest = Test-ModuleManifest -Path $script:moduleToTest -ErrorAction Stop -WarningAction SilentlyContinue

        $script:manifestData = Import-PowerShellDataFile -Path $env:BHManifestToTest
    }
    AfterEach {
        Get-ChildItem TestDrive:\FunctionCalled* | Remove-Item
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "imports '$env:BHProjectName' cleanly" {
        { Import-Module $script:moduleToTest -ErrorAction Stop } | Should -Not -Throw

        $module = Get-Module $env:BHProjectName
        $module | Should -BeOfType [PSModuleInfo]
    }

    It "has public functions" {
        Import-Module $script:moduleToTest
        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "uses the correct root module" {
        $manifest.RootModule | Should -Be 'AtlassianPS.Configuration.psm1'
    }

    It "uses the correct guid" {
        $manifest.Guid | Should -Be 'f946e1f7-ed4f-43da-aa24-6d57a25117cb'
    }

    It "uses a valid version" {
        $manifest.Version | Should -Not -BeNullOrEmpty
        [Version]$manifest.Version | Should -BeOfType [Version]
    }

    It "requires Configuration" {
        $requiredModules = @(
            foreach ($requiredModule in @($manifestData.RequiredModules)) {
                if ($requiredModule -is [string]) {
                    $requiredModule
                    continue
                }

                if ($requiredModule -is [hashtable]) {
                    $requiredModule.ModuleName
                    continue
                }

                if ($requiredModule.PSObject.Properties.Name -contains 'ModuleName') {
                    $requiredModule.ModuleName
                }
            }
        )
        $requiredModules | Should -Contain 'Configuration'
    }

    It "loads Configuration into the global scope" {
        Remove-Module Configuration -Force -ErrorAction SilentlyContinue
        (Get-Module).Name | Should -Not -Contain Configuration
        Import-Module $script:moduleToTest -Force
        (Get-Module).Name | Should -Contain Configuration

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }

    It "loads saved configurations states on import" {
        Test-Path "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -Be $false

        New-Alias -Name Import-Configuration -Value LogCall -Scope Global
        Import-Module $script:moduleToTest
        Remove-Item alias:\Import-Configuration -ErrorAction SilentlyContinue

        "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -FileContentMatchExactly "Import-Configuration"
    }

    It "module is imported with default prefix" {
        $prefix = $manifestData.DefaultCommandPrefix

        Import-Module $env:BHManifestToTest -Force -ErrorAction Stop
        (Get-Command -Module $env:BHProjectName -CommandType Function).Name | ForEach-Object {
            $_ | Should -Match "\-$prefix"
        }
    }

    It "module is imported with custom prefix" {
        $prefix = "Test"

        Import-Module $env:BHManifestToTest -Prefix $prefix -Force -ErrorAction Stop
        (Get-Command -Module $env:BHProjectName -CommandType Function).Name | ForEach-Object {
            $_ | Should -Match "\-$prefix"
        }
    }
}
