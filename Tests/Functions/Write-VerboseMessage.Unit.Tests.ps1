#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe "Write-VerboseMessage" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    It "honors a caller's verbose switch across the module boundary" {
        function Invoke-ExternalVerboseMessage {
            [CmdletBinding()]
            param([Switch] $Suppress)

            if ($Suppress) {
                Write-AtlassianVerboseMessage -BoundParameters $PSBoundParameters -Cmdlet $PSCmdlet -Verbose:$false
            }
            else {
                Write-AtlassianVerboseMessage -BoundParameters $PSBoundParameters -Cmdlet $PSCmdlet
            }
        }

        (Invoke-ExternalVerboseMessage -Verbose 4>&1 | Out-String) | Should -Match 'PSBoundParameters:'
        Invoke-ExternalVerboseMessage -Verbose -Suppress 4>&1 | Should -BeNullOrEmpty
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

            It "has an IDictionary -BoundParameters parameter in its own parameter set" {
                $command.Parameters["BoundParameters"].ParameterType | Should -Be 'System.Collections.IDictionary'
                $command.ParameterSets.Name | Should -Contain 'BoundParameters'
                $command.ParameterSets.Name | Should -Contain 'Message'
            }

            It "has a [System.Management.Automation.PSCmdlet] -Cmdlet parameter" {
                $command.Parameters.ContainsKey("Cmdlet")
                $command.Parameters["Cmdlet"].ParameterType | Should -Be "System.Management.Automation.PSCmdlet"
            }
        }

        Context "Behavior checking" {
            It "honors an explicit false Verbose switch inside a verbose-enabled caller" {
                function Invoke-QuietVerboseMessage {
                    [CmdletBinding()]
                    param()

                    Write-VerboseMessage -Message 'suppressed-message' -Verbose:$false
                }

                Invoke-QuietVerboseMessage -Verbose 4>&1 | Should -BeNullOrEmpty
            }

            It "skips redaction and formatting when explicitly suppressed" {
                Mock Protect-BoundParameter { throw 'Unexpected redaction' }
                Mock Format-MessageStyle { throw 'Unexpected formatting' }

                Write-VerboseMessage -BoundParameters @{ ApiToken = 'sentinel-token' } -Verbose:$false 4>&1 | Should -BeNullOrEmpty

                Should -Invoke Protect-BoundParameter -Times 0 -Exactly
                Should -Invoke Format-MessageStyle -Times 0 -Exactly
            }

            It "does not enable output because a caller argument contains Verbose" {
                function Invoke-VerboseArgument {
                    [CmdletBinding()]
                    param([String] $Text)

                    Write-VerboseMessage -Message $Text
                }

                $VerbosePreference = 'SilentlyContinue'
                Invoke-VerboseArgument -Text 'Verbose sentinel-message' 4>&1 | Should -BeNullOrEmpty
            }

            It "skips work when VerbosePreference is <Preference>" -ForEach @(
                @{ Preference = 'SilentlyContinue' }
                @{ Preference = 'Ignore' }
            ) {
                Mock Protect-BoundParameter { throw 'Unexpected redaction' }
                Mock Format-MessageStyle { throw 'Unexpected formatting' }
                $VerbosePreference = $Preference

                Write-VerboseMessage -BoundParameters @{ ApiToken = 'sentinel-token' } 4>&1 | Should -BeNullOrEmpty

                Should -Invoke Protect-BoundParameter -Times 0 -Exactly
                Should -Invoke Format-MessageStyle -Times 0 -Exactly
            }

            It "retains safe parameters without exposing authentication or request payloads" {
                $password = [SecureString]::new()
                $password.AppendChar('x')
                $parameters = @{
                    Key           = 'TEST-1'
                    ApiToken      = 'sentinel-token'
                    Cookie        = 'sentinel-cookie'
                    Authorization = 'sentinel-authorization'
                    First         = [PSCredential]::new('sentinel-user', $password)
                    Second        = $password
                    Headers       = @{ Authorization = 'sentinel-header' }
                    Body          = 'sentinel-body'
                    GetParameter  = @{ token = 'sentinel-query' }
                    Uri           = [Uri]'https://sentinel-user:sentinel-password@example.com/path?token=sentinel-uri#sentinel-fragment'
                    RelativeUri   = [Uri]::new('/rest/api/2/issue?token=sentinel-relative#sentinel-fragment', [UriKind]::Relative)
                }

                $output = Write-VerboseMessage -BoundParameters $parameters -Verbose 4>&1 | Out-String

                $output | Should -Match 'PSBoundParameters:'
                $output | Should -Match 'TEST-1'
                $output | Should -Match 'https://example.com/path'
                $output | Should -Match '/rest/api/2/issue'
                $output | Should -Match '\[REDACTED\]'
                $output | Should -Not -Match 'sentinel-'
                $parameters.ApiToken | Should -Be 'sentinel-token'
                $parameters.Uri.UserInfo | Should -Be 'sentinel-user:sentinel-password'
                $parameters.First.UserName | Should -Be 'sentinel-user'
                $password.Length | Should -Be 1
            }

            It "keeps positional message and cmdlet arguments compatible" {
                function Invoke-PositionalVerboseMessage {
                    [CmdletBinding()]
                    param()

                    Write-VerboseMessage 'positional-message' $PSCmdlet
                }

                $output = Invoke-PositionalVerboseMessage -Verbose 4>&1 | Out-String

                $output | Should -Match 'positional-message'
            }

            It "accepts multiple pipeline messages without sanitizing arbitrary text" {
                $output = 'sentinel-message', 'second-message' | Write-VerboseMessage -Verbose 4>&1

                @($output).Count | Should -Be 2
                ($output | Out-String) | Should -Match 'sentinel-message'
                ($output | Out-String) | Should -Match 'second-message'
            }

            It "writes verbose output" {
                $originalPreference = $VerbosePreference
                $VerbosePreference = 'Continue'

                try {
                    $verboseOutput = Write-VerboseMessage -Message 'verbose-message' 4>&1

                    $VerbosePreference | Should -Be 'Continue'
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

                    $verboseOutput | Should -Match '(?s)\[.*>.*\]:'
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
