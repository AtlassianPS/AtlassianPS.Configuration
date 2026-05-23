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
        $messageSettings = $script:Configuration["Message"]
        if (-not $messageSettings) {
            $messageSettings = [AtlassianPS.MessageStyle]::new()
        }

        $oldDebugPreference = $DebugPreference
        if (-not $BreakPoint -and $DebugPreference -ne 'SilentlyContinue') {
            $DebugPreference = 'Continue'
        }
    }

    process {
        $indent, $functionName, $timeStamp = ""

        $caller = Get-PSCallStack | Select-Object -Last 1 -Skip 1 | Select-Object -First 1
        if ($caller -and $caller.Arguments -and $caller.Arguments.Contains("Debug")) {
            $DebugPreference = 'Continue'
        }

        if ($messageSettings.BreadCrumbs) {
            WriteDebug "[$(Get-BreadCrumb)]:"
            if ($messageSettings.Indent) {
                $indent = " " * $messageSettings.Indent
            }
            else {
                $indent = " " * 4
            }
        }
        elseif ($messageSettings.FunctionName -and $Cmdlet) {
            $functionName = "[$($Cmdlet.MyInvocation.MyCommand.Name)] "
        }

        if ($messageSettings.TimeStamp) {
            $timeStamp = "[$(Get-Date -Format "HH:mm:ss")] "
        }

        WriteDebug ("{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message)
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
