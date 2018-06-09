#requires -modules Pester

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Import-Module BuildHelpers
        Remove-Item -Path Env:\BH*
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        # Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHPSModuleManifest -ErrorAction Stop } | Should -Not -Throw
    }

    It "module '$env:BHProjectName' can import cleanly" {
        { Import-Module $env:BHPSModuleManifest } | Should Not Throw
    }

    It "module '$env:BHProjectName' exports functions" {
        Import-Module $env:BHPSModuleManifest

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        Get-Metadata -Path $env:BHPSModuleManifest -PropertyName RootModule | Should -Be 'AtlassianPS.Configuration.psm1'
    }

    It "module uses the correct guid" {
        Get-Metadata -Path $env:BHPSModuleManifest -PropertyName Guid | Should -Be 'f946e1f7-ed4f-43da-aa24-6d57a25117cb'
    }

    It "module uses a valid version" {
        [Version](Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }
}
