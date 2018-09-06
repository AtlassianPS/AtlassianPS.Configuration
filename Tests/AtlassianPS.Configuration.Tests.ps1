#requires -modules @{ ModuleName = "BuildHelpers"; ModuleVersion = "1.2" }
#requires -modules Pester

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/..").Path
        if ($projectRoot -like "*Release") {
            $projectRoot = (Resolve-Path "$projectRoot/..").Path
        }

        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

        $env:BHManifestToTest = $env:BHPSModuleManifest
        $script:isBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
        if ($script:isBuild) {
            $Pattern = [regex]::Escape($env:BHProjectPath)

            $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
            $env:BHManifestToTest = $env:BHBuildModuleManifest
        }

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        # Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module BuildTools
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }
    AfterEach {
        Get-ChildItem TestDrive:\FunctionCalled* | Remove-Item
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "module '$env:BHProjectName' can import cleanly" {
        { Import-Module $env:BHManifestToTest } | Should Not Throw
    }

    It "module '$env:BHProjectName' exports functions" {
        Import-Module $env:BHManifestToTest

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName RootModule | Should -Be 'AtlassianPS.Configuration.psm1'
    }

    It "module uses the correct guid" {
        Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName Guid | Should -Be 'f946e1f7-ed4f-43da-aa24-6d57a25117cb'
    }

    It "module uses a valid version" {
        [Version](Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }

    It "module requires Configuration" {
        # this workaround will be obsolete with
        # https://github.com/PoshCode/Configuration/pull/20
        $pureExpression = Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName RequiredModules -Passthru
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
}
