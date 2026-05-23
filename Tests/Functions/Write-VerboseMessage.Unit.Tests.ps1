#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Write-VerboseMessage" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name Write-VerboseMessage
            }

            It "has a [String] -Message parameter" {
                $command.Parameters.ContainsKey("Message")
                $command.Parameters["Message"].ParameterType | Should -Be "String"
            }

            It "has a [System.Management.Automation.PSCmdlet] -Cmdlet parameter" {
                $command.Parameters.ContainsKey("Cmdlet")
                $command.Parameters["Cmdlet"].ParameterType | Should -Be "System.Management.Automation.PSCmdlet"
            }
        }

        Context "Behavior checking" {
            It "writes verbose output" {
                $originalPreference = $VerbosePreference
                $VerbosePreference = 'Continue'

                try {
                    $verboseOutput = Write-VerboseMessage -Message 'verbose-message' 4>&1

                    ($verboseOutput | Out-String) | Should -Match 'verbose-message'
                }
                finally {
                    $VerbosePreference = $originalPreference
                }
            }

            It "accepts messages from the pipeline" {
                $originalPreference = $VerbosePreference
                $VerbosePreference = 'Continue'

                try {
                    $verboseOutput = 'pipeline-message' | Write-VerboseMessage 4>&1

                    ($verboseOutput | Out-String) | Should -Match 'pipeline-message'
                }
                finally {
                    $VerbosePreference = $originalPreference
                }
            }

            It "honors message style breadcrumbs and indentation" {
                $originalPreference = $VerbosePreference
                $originalMessageStyle = $script:Configuration["Message"]
                $VerbosePreference = 'Continue'
                $script:Configuration["Message"] = [AtlassianPS.MessageStyle]::new(2, $false, $true, $false)

                try {
                    function Invoke-TestWriteVerboseMessage {
                        [CmdletBinding()]
                        param()

                        Write-VerboseMessage -Message 'crumb-message'
                    }

                    $verboseOutput = (Invoke-TestWriteVerboseMessage 4>&1 | Out-String)

                    $verboseOutput | Should -Match '\[.*>.*\]:'
                    $verboseOutput | Should -Match '\s{2}crumb-message'
                }
                finally {
                    $script:Configuration["Message"] = $originalMessageStyle
                    $VerbosePreference = $originalPreference
                }
            }

            It "uses the caller command name for function-name formatting" {
                $originalPreference = $VerbosePreference
                $originalMessageStyle = $script:Configuration["Message"]
                $VerbosePreference = 'Continue'
                $script:Configuration["Message"] = [AtlassianPS.MessageStyle]::new(0, $false, $false, $true)

                try {
                    function Invoke-TestWriteVerboseMessageFunctionName {
                        [CmdletBinding()]
                        param()

                        Write-VerboseMessage -Message 'function-name-message'
                    }

                    $verboseOutput = (Invoke-TestWriteVerboseMessageFunctionName 4>&1 | Out-String)

                    $verboseOutput | Should -Match '\[Invoke-TestWriteVerboseMessageFunctionName\] function-name-message'
                }
                finally {
                    $script:Configuration["Message"] = $originalMessageStyle
                    $VerbosePreference = $originalPreference
                }
            }
        }
    }
}
