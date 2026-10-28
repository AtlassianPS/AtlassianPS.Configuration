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
            $parameters = Protect-BoundParameter -BoundParameters $BoundParameters
            $Message = "PSBoundParameters: $($parameters | Out-String)"
        }

        Format-MessageStyle -Message $Message -Cmdlet $Cmdlet | ForEach-Object { WriteDebug $_ }
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
