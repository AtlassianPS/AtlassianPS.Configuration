#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "New-ErrorRecord" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "creates error records for existing exceptions" {
            $record = New-ErrorRecord `
                -Mode ExistingException `
                -Exception ([System.InvalidOperationException]::new("oops")) `
                -ErrorId "Record.Test" `
                -Category InvalidOperation

            $record | Should -BeOfType [System.Management.Automation.ErrorRecord]
            $record.Exception.Message | Should -Be "oops"
        }

        It "throws when exception is missing for existing mode" {
            {
                New-ErrorRecord -Mode ExistingException -ErrorId "Record.Test" -Category InvalidOperation
            } | Should -Throw -ExpectedMessage "*Exception is required*"
        }

        It "creates wrapped exceptions for new-exception mode" {
            $record = New-ErrorRecord `
                -Mode NewException `
                -Message "outer" `
                -Exception ([System.ArgumentException]::new("inner")) `
                -ErrorId "Record.NewException" `
                -Category InvalidOperation

            $record.Exception.Message | Should -Be "outer"
            $record.Exception.InnerException.Message | Should -Be "inner"
        }
    }
}

