#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe 'Tools/update.dependencies.ps1' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:projectRoot = Resolve-ProjectRoot

        function Assert-ThrowsMessage {
            param(
                [Parameter(Mandatory)]
                [ScriptBlock]$ScriptBlock,

                [Parameter(Mandatory)]
                [String]$MessagePattern
            )

            $capturedError = $null
            try {
                & $ScriptBlock
            }
            catch {
                $capturedError = $_
            }

            $capturedError | Should -Not -BeNullOrEmpty
            $capturedError.Exception.Message | Should -Match $MessagePattern
        }
    }

    It 'delegates dependency updates to AtlassianPS.Standards command with explicit module qualification' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/0.1.6'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'update.dependencies.ps1'
        $updateCapturePath = Join-Path -Path $TestDrive -ChildPath 'update-capture.json'
        $escapedUpdateCapturePath = $updateCapturePath.Replace("'", "''")

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'update.dependencies.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "0.1.6" }
)
'@

        Set-Content -LiteralPath (Join-Path -Path $modulePath -ChildPath 'AtlassianPS.Configuration.psd1') -Value @'
@{
    RootModule      = 'AtlassianPS.Configuration.psm1'
    ModuleVersion   = '1.6'
    RequiredModules = @()
}
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psm1') -Value @"
function Update-AtlassianPSDependencyReference {
    [CmdletBinding()]
    param(
        [String]`$BuildRequirementsPath,
        [String]`$ManifestPath,
        [Switch]`$SkipBuildRequirement,
        [Switch]`$SkipManifestRequirement,
        [Switch]`$AllowMajorVersionUpgrade
    )

    [PSCustomObject]@{
        BuildRequirementsPath   = `$BuildRequirementsPath
        ManifestPath            = `$ManifestPath
        SkipBuildRequirement    = [Boolean]`$SkipBuildRequirement
        SkipManifestRequirement = [Boolean]`$SkipManifestRequirement
        AllowMajorVersionUpgrade = [Boolean]`$AllowMajorVersionUpgrade
    } | ConvertTo-Json -Compress | Set-Content -LiteralPath '$escapedUpdateCapturePath'

    return [PSCustomObject]@{
        Updated = `$true
    }
}

Export-ModuleMember -Function Update-AtlassianPSDependencyReference
"@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '0.1.6'
    GUID              = 'f184fdb6-7ed1-4557-8ad4-25979adf391e'
    FunctionsToExport = @('*')
}
'@

        Mock -CommandName Get-PSRepository -MockWith {
            [PSCustomObject]@{
                Name               = 'PSGallery'
                SourceLocation     = 'https://www.powershellgallery.com/api/v2/'
                InstallationPolicy = 'Trusted'
            }
        }
        Mock -CommandName Register-PSRepository -MockWith {}
        Mock -CommandName Get-PackageProvider -MockWith { [PSCustomObject]@{ Name = 'NuGet'; Version = [Version] '2.8.5.208' } }
        Mock -CommandName Install-PackageProvider -MockWith {}
        Mock -CommandName Set-PSRepository -MockWith {}
        Mock -CommandName Install-Module -MockWith {}

        $moduleSearchPath = Join-Path -Path $harnessRoot -ChildPath 'mockModules'
        $originalModulePath = $env:PSModulePath
        $env:PSModulePath = "$moduleSearchPath$([System.IO.Path]::PathSeparator)$originalModulePath"
        try {
            $result = & $scriptPath -SkipManifestRequirement -AllowMajorVersionUpgrade
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }

        $capturedUpdate = Get-Content -LiteralPath $updateCapturePath -Raw | ConvertFrom-Json
        $capturedUpdate.BuildRequirementsPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'Tools/build.requirements.psd1')
        $capturedUpdate.ManifestPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration/AtlassianPS.Configuration.psd1')
        $capturedUpdate.SkipBuildRequirement | Should -BeFalse
        $capturedUpdate.SkipManifestRequirement | Should -BeTrue
        $capturedUpdate.AllowMajorVersionUpgrade | Should -BeTrue
        $result.Updated | Should -BeTrue
    }

    It 'returns a skipped result and does not update when invoked with WhatIf' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/0.1.6'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'update.dependencies.ps1'

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'update.dependencies.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "0.1.6" }
)
'@

        Set-Content -LiteralPath (Join-Path -Path $modulePath -ChildPath 'AtlassianPS.Configuration.psd1') -Value @'
@{
    RootModule      = 'AtlassianPS.Configuration.psm1'
    ModuleVersion   = '1.6'
    RequiredModules = @()
}
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psm1') -Value @'
function Update-AtlassianPSDependencyReference {
    [CmdletBinding()]
    param(
        [String]$BuildRequirementsPath,
        [String]$ManifestPath,
        [Switch]$SkipBuildRequirement,
        [Switch]$SkipManifestRequirement,
        [Switch]$AllowMajorVersionUpgrade
    )

    throw "Update-AtlassianPSDependencyReference should not be called under WhatIf."
}

Export-ModuleMember -Function Update-AtlassianPSDependencyReference
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '0.1.6'
    GUID              = 'd44740cc-cfba-4f50-9666-d72f55ad247f'
    FunctionsToExport = @('*')
}
'@

        Mock -CommandName Get-PSRepository -MockWith {
            [PSCustomObject]@{
                Name               = 'PSGallery'
                SourceLocation     = 'https://www.powershellgallery.com/api/v2/'
                InstallationPolicy = 'Trusted'
            }
        }
        Mock -CommandName Register-PSRepository -MockWith {}
        Mock -CommandName Get-PackageProvider -MockWith { [PSCustomObject]@{ Name = 'NuGet'; Version = [Version] '2.8.5.208' } }
        Mock -CommandName Install-PackageProvider -MockWith {}
        Mock -CommandName Set-PSRepository -MockWith {}
        Mock -CommandName Install-Module -MockWith {}

        $moduleSearchPath = Join-Path -Path $harnessRoot -ChildPath 'mockModules'
        $originalModulePath = $env:PSModulePath
        $env:PSModulePath = "$moduleSearchPath$([System.IO.Path]::PathSeparator)$originalModulePath"
        try {
            $result = & $scriptPath -WhatIf
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }

        $result.Skipped | Should -BeTrue
        $result.BuildRequirementsPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'Tools/build.requirements.psd1')
        $result.ManifestPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration/AtlassianPS.Configuration.psd1')
    }

    It 'fails fast when shared updater emits a non-terminating error' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/0.1.6'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'update.dependencies.ps1'

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'update.dependencies.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "0.1.6" }
)
'@

        Set-Content -LiteralPath (Join-Path -Path $modulePath -ChildPath 'AtlassianPS.Configuration.psd1') -Value @'
@{
    RootModule      = 'AtlassianPS.Configuration.psm1'
    ModuleVersion   = '1.6'
    RequiredModules = @()
}
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psm1') -Value @'
function Update-AtlassianPSDependencyReference {
    [CmdletBinding()]
    param(
        [String]$BuildRequirementsPath,
        [String]$ManifestPath,
        [Switch]$SkipBuildRequirement,
        [Switch]$SkipManifestRequirement,
        [Switch]$AllowMajorVersionUpgrade
    )

    Write-Error -Message "simulated update failure"
}

Export-ModuleMember -Function Update-AtlassianPSDependencyReference
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '0.1.6'
    GUID              = 'e08b79c8-d939-4e3d-903f-c50d4a5ccf72'
    FunctionsToExport = @('*')
}
'@

        Mock -CommandName Get-PSRepository -MockWith {
            [PSCustomObject]@{
                Name               = 'PSGallery'
                SourceLocation     = 'https://www.powershellgallery.com/api/v2/'
                InstallationPolicy = 'Trusted'
            }
        }
        Mock -CommandName Register-PSRepository -MockWith {}
        Mock -CommandName Get-PackageProvider -MockWith { [PSCustomObject]@{ Name = 'NuGet'; Version = [Version] '2.8.5.208' } }
        Mock -CommandName Install-PackageProvider -MockWith {}
        Mock -CommandName Set-PSRepository -MockWith {}
        Mock -CommandName Install-Module -MockWith {}

        $moduleSearchPath = Join-Path -Path $harnessRoot -ChildPath 'mockModules'
        $originalModulePath = $env:PSModulePath
        $env:PSModulePath = "$moduleSearchPath$([System.IO.Path]::PathSeparator)$originalModulePath"
        try {
            Assert-ThrowsMessage -ScriptBlock { & $scriptPath | Out-Null } -MessagePattern 'simulated update failure'
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }
    }
}
