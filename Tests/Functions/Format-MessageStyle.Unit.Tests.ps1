#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Format-MessageStyle" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "formats messages with breadcrumbs and indentation" {
            function Invoke-TestFormatMessageStyle {
                [CmdletBinding()]
                param()

                Format-MessageStyle `
                    -Message 'styled-message' `
                    -MessageSettings ([AtlassianPS.MessageStyle]::new(2, $false, $true, $false))
            }

            $output = Invoke-TestFormatMessageStyle

            $output | Should -HaveCount 2
            $output[0] | Should -Match '\[.*>.*\]:'
            $output[0] | Should -Not -Match 'Format-MessageStyle'
            $output[1] | Should -Be '  styled-message'
        }

        It "formats messages with the caller command name" {
            function Invoke-TestFormatMessageStyleFunctionName {
                [CmdletBinding()]
                param()

                Format-MessageStyle `
                    -Message 'styled-message' `
                    -Cmdlet $PSCmdlet `
                    -MessageSettings ([AtlassianPS.MessageStyle]::new(0, $false, $false, $true))
            }

            Invoke-TestFormatMessageStyleFunctionName | Should -Be '[Invoke-TestFormatMessageStyleFunctionName] styled-message'
        }
    }
}
