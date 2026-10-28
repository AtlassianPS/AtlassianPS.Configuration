function Write-DebugMessage {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( DefaultParameterSetName = 'Message' )]
    param(
        [Parameter( Position = 0, ValueFromPipeline, ParameterSetName = 'Message' )]
        [String]
        $Message,

        [Parameter( Mandatory, ParameterSetName = 'BoundParameters' )]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter()]
        [Switch]
        $BreakPoint,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $(
            try {
                (Get-Variable -Scope 1 -Name PSCmdlet -ErrorAction Stop).Value
            }
            catch {
                $PSCmdlet
            }
        )
    )

    begin {
        Import-MqcnAlias -Alias "WriteDebug" -Command "Microsoft.PowerShell.Utility\Write-Debug"
        $oldDebugPreference = $DebugPreference
        if (-not $BreakPoint -and $DebugPreference -ne 'SilentlyContinue') {
            $DebugPreference = 'Continue'
        }
    }

    process {
        if (-not $PSBoundParameters.ContainsKey('Debug') -and -not $BreakPoint -and $Cmdlet.MyInvocation.BoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        if ($DebugPreference -eq 'SilentlyContinue') { return }

        if ($PSCmdlet.ParameterSetName -eq 'BoundParameters') {
            $parameters = [Ordered]@{}
            foreach ($key in $BoundParameters.Keys) {
                $value = $BoundParameters[$key]
                if ($key -match 'Credential|Password|Token|Secret|Cookie|Authorization|Headers|Body' -or
                    $value -is [PSCredential] -or $value -is [SecureString]
                ) {
                    $parameters[$key] = '[REDACTED]'
                }
                elseif ($null -eq $value) { $parameters[$key] = $null }
                elseif ($value -is [Uri]) {
                    if ($value.IsAbsoluteUri) {
                        $parameters[$key] = $value.GetComponents([UriComponents]'SchemeAndServer, Path', [UriFormat]::UriEscaped)
                    }
                    else { $parameters[$key] = ($value.OriginalString -split '[?#]', 2)[0] }
                }
                elseif ($value -is [String] -or $value.GetType().IsPrimitive -or $value -is [Switch]) {
                    $parameters[$key] = $value
                }
                else { $parameters[$key] = "[$($value.GetType().FullName)]" }
            }
            $Message = "PSBoundParameters: $($parameters | Out-String)"
        }

        Format-MessageStyle -Message $Message -Cmdlet $Cmdlet | ForEach-Object { WriteDebug $_ }
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
