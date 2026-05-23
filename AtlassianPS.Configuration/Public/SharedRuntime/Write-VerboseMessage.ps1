function Write-VerboseMessage {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $Message,

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
        Import-MqcnAlias -Alias "WriteVerbose" -Command "Microsoft.PowerShell.Utility\Write-Verbose"
    }

    process {
        $caller = Get-PSCallStack | Select-Object -Last 1 -Skip 1 | Select-Object -First 1
        if ($caller -and $caller.Arguments -and $caller.Arguments.Contains("Verbose")) {
            $VerbosePreference = 'Continue'
        }

        Format-MessageStyle -Message $Message -Cmdlet $Cmdlet | ForEach-Object { WriteVerbose $_ }
    }
}
