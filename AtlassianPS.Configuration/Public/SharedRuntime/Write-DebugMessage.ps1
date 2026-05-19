function Write-DebugMessage {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [String]
        $Message
    )

    begin {
        $oldDebugPreference = $DebugPreference
        if ($DebugPreference -ne 'SilentlyContinue') {
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
