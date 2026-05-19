#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Stop-ErrorRecord" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "throws a terminating error record" {
            function Invoke-TestStopErrorRecord {
                [CmdletBinding()]
                param()

                Stop-ErrorRecord `
                    -Message "outer-error" `
                    -Exception ([System.Exception]::new("inner-error")) `
                    -ErrorId "StopError.Record" `
                    -Category InvalidOperation
            }

            {
                Invoke-TestStopErrorRecord
            } | Should -Throw -ExpectedMessage "*outer-error*"
        }
    }
}

