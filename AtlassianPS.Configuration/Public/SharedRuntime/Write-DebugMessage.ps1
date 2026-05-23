function Write-DebugMessage {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [String]
        $Message,

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
        $caller = Get-PSCallStack | Select-Object -Last 1 -Skip 1 | Select-Object -First 1
        if ($caller -and $caller.Arguments -and $caller.Arguments.Contains("Debug")) {
            $DebugPreference = 'Continue'
        }

        Format-MessageStyle -Message $Message -Cmdlet $Cmdlet | ForEach-Object { WriteDebug $_ }
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
