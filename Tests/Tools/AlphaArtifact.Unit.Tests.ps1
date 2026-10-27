#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'Exact alpha artifact verification' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $root = Resolve-ProjectRoot
        Import-Module (Join-Path $root 'Tools/BuildTools.psm1') -Force
        Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
    }

    It 'accepts an exact manifest in a Windows-style ZIP entry' {
        $built = Join-Path $TestDrive 'windows-built.psd1'
        Set-Content -LiteralPath $built -Value "@{ModuleVersion='0.3.0';PrivateData=@{PSData=@{Prerelease='alpha0001';ReleaseNotes='Experimental candidate'}}}"
        $zip = Join-Path $TestDrive 'windows-candidate.zip'
        $archive = [IO.Compression.ZipFile]::Open($zip, [IO.Compression.ZipArchiveMode]::Create)
        try {
            $null = [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $built, 'AtlassianPS.Configuration\AtlassianPS.Configuration.psd1')
        }
        finally { $archive.Dispose() }

        {
            Test-ConfigurationArtifactVersion -BuiltManifestPath $built -PackagePath $zip -ExpectedVersion '0.3.0-alpha0001'
        } | Should -Not -Throw
    }

    It 'rejects a packaged prerelease with the same numeric version but another label' {
        $moduleRoot = Join-Path $TestDrive 'package/AtlassianPS.Configuration'
        $null = New-Item -Path $moduleRoot -ItemType Directory -Force
        $built = Join-Path $TestDrive 'built.psd1'
        $packaged = Join-Path $moduleRoot 'AtlassianPS.Configuration.psd1'
        $data = "@{ModuleVersion='0.3.0';PrivateData=@{PSData=@{Prerelease='alpha0001';ReleaseNotes='Experimental candidate'}}}"
        Set-Content -LiteralPath $built -Value $data
        Set-Content -LiteralPath $packaged -Value ($data.Replace('alpha0001', 'alpha0002'))
        $zip = Join-Path $TestDrive 'candidate.zip'
        [IO.Compression.ZipFile]::CreateFromDirectory((Split-Path $moduleRoot -Parent), $zip)
        {
            Test-ConfigurationArtifactVersion -BuiltManifestPath $built -PackagePath $zip -ExpectedVersion '0.3.0-alpha0001'
        } | Should -Throw '*prerelease*'
    }
}
