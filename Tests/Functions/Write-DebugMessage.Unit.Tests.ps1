#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Write-DebugMessage" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name Write-DebugMessage
            }

            It "has a [String] -Message parameter" {
                $command.Parameters.ContainsKey("Message")
                $command.Parameters["Message"].ParameterType | Should -Be "String"
            }

            It "does not expose legacy BreakPoint and Cmdlet parameters" {
                $command.Parameters.ContainsKey("BreakPoint") | Should -BeFalse
                $command.Parameters.ContainsKey("Cmdlet") | Should -BeFalse
            }
        }

        Context "Behavior checking" {
            It "writes debug output and preserves debug preference" {
                $originalPreference = $DebugPreference
                $DebugPreference = 'Continue'

                try {
                    $debugOutput = Write-DebugMessage -Message 'debug-message' 5>&1

                    $DebugPreference | Should -Be 'Continue'
                    ($debugOutput | Out-String) | Should -Match 'debug-message'
                }
                finally {
                    $DebugPreference = $originalPreference
                }
            }
        }
    }
}
