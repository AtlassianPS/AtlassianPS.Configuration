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
        $messageSettings = $script:Configuration["Message"]
        if (-not $messageSettings) {
            $messageSettings = [AtlassianPS.MessageStyle]::new()
        }
    }

    process {
        $indent, $functionName, $timeStamp = ""

        $caller = Get-PSCallStack | Select-Object -Last 1 -Skip 1 | Select-Object -First 1
        if ($caller -and $caller.Arguments -and $caller.Arguments.Contains("Verbose")) {
            $VerbosePreference = 'Continue'
        }

        if ($messageSettings.BreadCrumbs) {
            WriteVerbose "[$(Get-BreadCrumb)]:"
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

        WriteVerbose ("{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message)
    }
}
