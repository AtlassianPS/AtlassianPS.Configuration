#requires -modules Pester
#requires -modules PSScriptAnalyzer

Describe "PSScriptAnalyzer Tests" -Tag Unit {

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

    $Params = @{
        Path          = "$PSScriptRoot/../$env:BHProjectName"
        Settings      = "$PSScriptRoot/../PSScriptAnalyzerSettings.psd1"
        Severity      = @('Error', 'Warning')
        Recurse       = $true
        Verbose       = $false
        ErrorVariable = 'ErrorVariable'
        ErrorAction   = 'SilentlyContinue'
    }
    $ScriptWarnings = Invoke-ScriptAnalyzer @Params
    $scripts = Get-ChildItem "$PSScriptRoot/../$env:BHProjectName" -Include *.ps1, *.psm1 -Recurse

    foreach ($Script in $scripts) {
        $RelPath = $Script.FullName.Replace($env:BHProjectPath, '') -replace '^\\', ''

        Context "$RelPath" {

            $Rules = $ScriptWarnings |
                Where-Object {$_.ScriptPath -like $Script.FullName} |
                Select-Object -ExpandProperty RuleName -Unique

            It "Passes $rule" {
                foreach ($rule in $Rules) {
                    $BadLines = $ScriptWarnings |
                        Where-Object {$_.ScriptPath -like $Script.FullName -and $_.RuleName -like $rule} |
                        Select-Object -ExpandProperty Line
                    $BadLines | Should -Be $null
                }
            }

            $Exceptions = $ErrorVariable.Exception.Message |
                Where-Object {$_ -match [regex]::Escape($Script.FullName)}

            It "Has no parse errors" {
                foreach ($Exception in $Exceptions) {
                    $Exception | Should -Be $null
                }
                break
            }
        }
    }
}
