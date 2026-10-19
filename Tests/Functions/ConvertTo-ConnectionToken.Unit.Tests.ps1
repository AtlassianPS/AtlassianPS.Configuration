#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Nonsecret unit-test token fixture.')]
param()
Describe 'ConvertTo-ConnectionToken' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
    }

    InModuleScope AtlassianPS.Configuration {
        It 'enforces the shared contract at its boundary' {

            $original = ConvertTo-SecureString 'sentinel' -AsPlainText -Force
            $copy = ConvertTo-ConnectionToken -Token $original

            [Object]::ReferenceEquals($copy, $original) | Should -BeFalse
            $copy.Dispose()

            $original.Length | Should -Be 8
            { ConvertTo-ConnectionToken -Token 42 } | Should -Throw

        }
    }
}
