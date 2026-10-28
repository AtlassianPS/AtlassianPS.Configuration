function Write-VerboseMessage {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( DefaultParameterSetName = 'Message' )]
    param(
        [Parameter( Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = 'Message' )]
        [String]
        $Message,

        [Parameter( Mandatory, ParameterSetName = 'BoundParameters' )]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter( Position = 1, ParameterSetName = 'Message' )]
        [Parameter( ParameterSetName = 'BoundParameters' )]
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
        Import-MqcnAlias -Alias "WriteVerbose" -Command "Microsoft.PowerShell.Utility\Write-Verbose"
    }

    process {
        if (-not $PSBoundParameters.ContainsKey('Verbose') -and $Cmdlet.MyInvocation.BoundParameters['Verbose']) {
            $VerbosePreference = 'Continue'
        }

        if ($VerbosePreference -in 'SilentlyContinue', 'Ignore') { return }

        if ($PSCmdlet.ParameterSetName -eq 'BoundParameters') {
            $parameters = Protect-BoundParameter -BoundParameters $BoundParameters
            $Message = "PSBoundParameters: $($parameters | Out-String)"
        }

        Format-MessageStyle -Message $Message -Cmdlet $Cmdlet | ForEach-Object { WriteVerbose $_ }
    }
}
