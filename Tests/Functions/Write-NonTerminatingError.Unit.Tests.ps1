#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Write-NonTerminatingError" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "writes a non-terminating error record" {
            function Invoke-TestWriteNonTerminatingError {
                [CmdletBinding()]
                param()

                Write-NonTerminatingError `
                    -Exception ([System.Exception]::new("write-error")) `
                    -ErrorId "WriteNonTerminatingError.Record" `
                    -Category InvalidOperation
            }

            $errorRecords = @()
            Invoke-TestWriteNonTerminatingError -ErrorAction SilentlyContinue -ErrorVariable +errorRecords

            $errorRecords | Should -Not -BeNullOrEmpty
            $errorRecords[0].Exception.Message | Should -Be "write-error"
            $errorRecords[0].CategoryInfo.Category | Should -Be "InvalidOperation"
            $errorRecords[0].InvocationInfo.MyCommand.Name | Should -Be "Invoke-TestWriteNonTerminatingError"
        }
    }
}

