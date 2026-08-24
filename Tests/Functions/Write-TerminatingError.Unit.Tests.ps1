#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe "Write-TerminatingError" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "throws a terminating error record" {
            function Invoke-TestWriteTerminatingError {
                [CmdletBinding()]
                param()

                Write-TerminatingError `
                    -Message "outer-error" `
                    -Exception ([System.Exception]::new("inner-error")) `
                    -ErrorId "WriteTerminatingError.Record" `
                    -Category InvalidOperation
            }

            try {
                Invoke-TestWriteTerminatingError
                throw "Expected Invoke-TestWriteTerminatingError to throw."
            }
            catch {
                $_.Exception.Message | Should -BeLike "*outer-error*"
                $_.InvocationInfo.MyCommand.Name | Should -Be "Invoke-TestWriteTerminatingError"
            }
        }
    }
}

