#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe "Write-DebugMessage" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    It "honors a caller's debug switch across the module boundary" {
        function Invoke-ExternalDebugMessage {
            [CmdletBinding()]
            param([Switch] $Suppress)

            if ($Suppress) {
                Write-AtlassianDebugMessage -BoundParameters $PSBoundParameters -Cmdlet $PSCmdlet -Debug:$false
            }
            else {
                Write-AtlassianDebugMessage -BoundParameters $PSBoundParameters -Cmdlet $PSCmdlet
            }
        }

        (Invoke-ExternalDebugMessage -Debug 5>&1 | Out-String) | Should -Match 'PSBoundParameters:'
        Invoke-ExternalDebugMessage -Debug -Suppress 5>&1 | Should -BeNullOrEmpty
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
            It "skips redaction and formatting when explicitly suppressed" {
                Mock Protect-BoundParameter { throw 'Unexpected redaction' }
                Mock Format-MessageStyle { throw 'Unexpected formatting' }

                Write-DebugMessage -BoundParameters @{ ApiToken = 'sentinel-token' } -Debug:$false 5>&1 | Should -BeNullOrEmpty

                Should -Invoke Protect-BoundParameter -Times 0 -Exactly
                Should -Invoke Format-MessageStyle -Times 0 -Exactly
            }

            It "accepts pipeline messages without sanitizing arbitrary text" {
                $output = 'sentinel-message', 'second-message' | Write-DebugMessage -Debug 5>&1

                @($output).Count | Should -Be 2
                ($output | Out-String) | Should -Match 'sentinel-message'
                ($output | Out-String) | Should -Match 'second-message'
            }

            It "honors an explicit false Debug switch inside a debug-enabled caller" {
                function Invoke-QuietDebugMessage {
                    [CmdletBinding()]
                    param()

                    Write-DebugMessage -Message 'suppressed-message' -Debug:$false
                }

                Invoke-QuietDebugMessage -Debug 5>&1 | Should -BeNullOrEmpty
            }

            It "retains parameter values without exposing authentication or request payloads" {
                $password = [SecureString]::new()
                foreach ($character in 'sentinel-credential'.ToCharArray()) { $password.AppendChar($character) }
                $parameters = @{
                    Key                 = 'TEST-1'
                    ApiToken            = 'sentinel-token'
                    PersonalAccessToken = 'sentinel-pat'
                    Password            = 'sentinel-password'
                    Credential          = [PSCredential]::new('sentinel-user', $password)
                    SecretValue         = 'sentinel-secret'
                    Headers             = @{ Authorization = 'sentinel-header' }
                    Body                = 'sentinel-body'
                    GetParameter        = @{ token = 'sentinel-query' }
                    Uri                 = [Uri]'https://sentinel-user:sentinel-password@example.com/path?token=sentinel-uri'
                    RelativeUri         = [Uri]'/rest/api/2/issue?token=sentinel-relative'
                }

                $output = Write-DebugMessage -BoundParameters $parameters -Debug 5>&1 | Out-String

                $output | Should -Match 'PSBoundParameters:'
                $output | Should -Match 'TEST-1'
                $output | Should -Match 'https://example.com/path'
                $output | Should -Match '/rest/api/2/issue'
                $output | Should -Match '\[REDACTED\]'
                $output | Should -Not -Match 'sentinel-'
                $parameters.ApiToken | Should -Be 'sentinel-token'
                $parameters.Uri.UserInfo | Should -Be 'sentinel-user:sentinel-password'
            }

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
