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
        $Cmdlet = $PSCmdlet
    )

    begin {
        $oldDebugPreference = $DebugPreference
        if (-not $BreakPoint -and $DebugPreference -ne 'SilentlyContinue') {
            $DebugPreference = 'Continue'
        }
    }

    process {
        Write-Debug -Message $Message
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
