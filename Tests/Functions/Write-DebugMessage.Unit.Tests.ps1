#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

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

            It "has a [Switch] -BreakPoint parameter" {
                $command.Parameters.ContainsKey("BreakPoint")
                $command.Parameters["BreakPoint"].ParameterType | Should -Be "Switch"
            }

            It "has a [System.Management.Automation.PSCmdlet] -Cmdlet parameter" {
                $command.Parameters.ContainsKey("Cmdlet")
                $command.Parameters["Cmdlet"].ParameterType | Should -Be "System.Management.Automation.PSCmdlet"
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

            It "honors message style breadcrumbs and indentation" {
                $originalPreference = $DebugPreference
                $originalMessageStyle = $script:Configuration["Message"]
                $DebugPreference = 'Continue'
                $script:Configuration["Message"] = [AtlassianPS.MessageStyle]::new(2, $false, $true, $false)

                try {
                    function Invoke-TestWriteDebugMessage {
                        [CmdletBinding()]
                        param()

                        Write-DebugMessage -Message 'crumb-message'
                    }

                    $debugOutput = (Invoke-TestWriteDebugMessage 5>&1 | Out-String)

                    $debugOutput | Should -Match '(?s)\[.*>.*\]:'
                    $debugOutput | Should -Match '\s{2}crumb-message'
                }
                finally {
                    $script:Configuration["Message"] = $originalMessageStyle
                    $DebugPreference = $originalPreference
                }
            }

            It "uses the caller command name for function-name formatting" {
                $originalPreference = $DebugPreference
                $originalMessageStyle = $script:Configuration["Message"]
                $DebugPreference = 'Continue'
                $script:Configuration["Message"] = [AtlassianPS.MessageStyle]::new(0, $false, $false, $true)

                try {
                    function Invoke-TestWriteDebugMessageFunctionName {
                        [CmdletBinding()]
                        param()

                        Write-DebugMessage -Message 'function-name-message'
                    }

                    $debugOutput = (Invoke-TestWriteDebugMessageFunctionName 5>&1 | Out-String)

                    $debugOutput | Should -Match '\[Invoke-TestWriteDebugMessageFunctionName\] function-name-message'
                }
                finally {
                    $script:Configuration["Message"] = $originalMessageStyle
                    $DebugPreference = $originalPreference
                }
            }
        }
    }
}
