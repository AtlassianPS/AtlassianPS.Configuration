#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe 'Tools/setup.ps1' -Tag Unit {
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

    It 'delegates dependency install and analyzer settings sync to shared standards commands' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/0.1.6'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'setup.ps1'
        $installCapturePath = Join-Path -Path $TestDrive -ChildPath 'setup-install.json'
        $syncCapturePath = Join-Path -Path $TestDrive -ChildPath 'setup-sync.txt'
        $escapedInstallCapturePath = $installCapturePath.Replace("'", "''")
        $escapedSyncCapturePath = $syncCapturePath.Replace("'", "''")

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'setup.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "0.1.6" }
    @{ ModuleName = "InvokeBuild"; RequiredVersion = "5.14.23" }
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
function Install-AtlassianPSDependencyRequirement {
    [CmdletBinding()]
    param(
        [String]`$BuildRequirementsPath,
        [String]`$ManifestPath
    )

    [PSCustomObject]@{
        BuildRequirementsPath = `$BuildRequirementsPath
        ManifestPath          = `$ManifestPath
    } | ConvertTo-Json -Compress | Set-Content -LiteralPath '$escapedInstallCapturePath'
}

function Sync-AtlassianPSScriptAnalyzerSettings {
    [CmdletBinding()]
    param(
        [String]`$DestinationPath
    )

    Set-Content -LiteralPath '$escapedSyncCapturePath' -Value `$DestinationPath
    return `$DestinationPath
}

Export-ModuleMember -Function Install-AtlassianPSDependencyRequirement, Sync-AtlassianPSScriptAnalyzerSettings
"@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '0.1.6'
    GUID              = '8f5c1a0f-b308-4cb5-a9ef-ab854f0f1626'
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
            & $scriptPath | Out-Null
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }

        $capturedInstall = Get-Content -LiteralPath $installCapturePath -Raw | ConvertFrom-Json
        $capturedSyncPath = (Get-Content -LiteralPath $syncCapturePath -Raw).TrimEnd("`r", "`n")

        $capturedInstall.BuildRequirementsPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'Tools/build.requirements.psd1')
        $capturedInstall.ManifestPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration/AtlassianPS.Configuration.psd1')
        $capturedSyncPath | Should -Be (Join-Path -Path $harnessRoot -ChildPath 'PSScriptAnalyzerSettings.psd1')
    }

    It 'installs the required standards version from build.requirements' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/9.9.9'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'setup.ps1'

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'setup.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "9.9.9" }
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
function Install-AtlassianPSDependencyRequirement {
    [CmdletBinding()]
    param(
        [String]$BuildRequirementsPath,
        [String]$ManifestPath
    )

    return [PSCustomObject]@{
        BuildRequirementsPath = $BuildRequirementsPath
        ManifestPath          = $ManifestPath
    }
}

function Sync-AtlassianPSScriptAnalyzerSettings {
    [CmdletBinding()]
    param(
        [String]$DestinationPath
    )

    return $DestinationPath
}

Export-ModuleMember -Function Install-AtlassianPSDependencyRequirement, Sync-AtlassianPSScriptAnalyzerSettings
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '9.9.9'
    GUID              = '2ab48fbd-b74f-4d5f-8f9b-0cbe6a8bc7e0'
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
        Mock -CommandName Install-Module -MockWith {}

        $moduleSearchPath = Join-Path -Path $harnessRoot -ChildPath 'mockModules'
        $originalModulePath = $env:PSModulePath
        $env:PSModulePath = "$moduleSearchPath$([System.IO.Path]::PathSeparator)$originalModulePath"
        try {
            $result = & $scriptPath
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }

        Assert-MockCalled -CommandName Install-Module -Exactly -Times 1 -ParameterFilter {
            $Name -eq 'AtlassianPS.Standards' -and
            $RequiredVersion -eq '9.9.9' -and
            $Scope -eq 'CurrentUser' -and
            $Repository -eq 'PSGallery' -and
            [Boolean]$AllowClobber -and
            [Boolean]$Force
        }
        $result | Should -Not -BeNullOrEmpty
    }

    It 'fails with clear guidance when PSGallery is unavailable after registration attempt' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'setup.ps1'

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'setup.ps1') -Destination $scriptPath

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

        Mock -CommandName Get-PSRepository -MockWith { $null }
        Mock -CommandName Register-PSRepository -MockWith {}
        Mock -CommandName Install-Module -MockWith {}

        Assert-ThrowsMessage -ScriptBlock { & $scriptPath } -MessagePattern 'PSGallery repository is unavailable'
    }

    It 'fails fast when shared installer emits a non-terminating error' {
        $sourceToolsPath = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
        $harnessRoot = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().ToString())
        $toolsPath = Join-Path -Path $harnessRoot -ChildPath 'Tools'
        $modulePath = Join-Path -Path $harnessRoot -ChildPath 'AtlassianPS.Configuration'
        $mockModulePath = Join-Path -Path $harnessRoot -ChildPath 'mockModules/AtlassianPS.Standards/0.1.6'
        $scriptPath = Join-Path -Path $toolsPath -ChildPath 'setup.ps1'

        $null = New-Item -Path $toolsPath -ItemType Directory -Force
        $null = New-Item -Path $modulePath -ItemType Directory -Force
        $null = New-Item -Path $mockModulePath -ItemType Directory -Force

        Copy-Item -LiteralPath (Join-Path -Path $sourceToolsPath -ChildPath 'setup.ps1') -Destination $scriptPath

        Set-Content -LiteralPath (Join-Path -Path $toolsPath -ChildPath 'build.requirements.psd1') -Value @'
@(
    @{ ModuleName = "AtlassianPS.Standards"; RequiredVersion = "0.1.6" }
    @{ ModuleName = "InvokeBuild"; RequiredVersion = "5.14.23" }
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
function Install-AtlassianPSDependencyRequirement {
    [CmdletBinding()]
    param(
        [String]$BuildRequirementsPath,
        [String]$ManifestPath
    )

    Write-Error -Message "simulated setup failure"
}

function Sync-AtlassianPSScriptAnalyzerSettings {
    [CmdletBinding()]
    param(
        [String]$DestinationPath
    )

    return $DestinationPath
}

Export-ModuleMember -Function Install-AtlassianPSDependencyRequirement, Sync-AtlassianPSScriptAnalyzerSettings
'@

        Set-Content -LiteralPath (Join-Path -Path $mockModulePath -ChildPath 'AtlassianPS.Standards.psd1') -Value @'
@{
    RootModule        = 'AtlassianPS.Standards.psm1'
    ModuleVersion     = '0.1.6'
    GUID              = 'b7a35107-f237-4ef7-a198-6111b16cb1ad'
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
            Assert-ThrowsMessage -ScriptBlock { & $scriptPath | Out-Null } -MessagePattern 'simulated setup failure'
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module -Name 'AtlassianPS.Standards' -Force -ErrorAction SilentlyContinue
        }
    }
}
