function Format-MessageStyle {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [String]
        $Message,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet,

        [Parameter()]
        [AllowNull()]
        [AtlassianPS.MessageStyle]
        $MessageSettings = $script:Configuration["Message"]
    )

    process {
        if (-not $MessageSettings) {
            $MessageSettings = [AtlassianPS.MessageStyle]::new()
        }

        $indent, $functionName, $timeStamp = ""

        if ($MessageSettings.BreadCrumbs) {
            "[$((Get-BreadCrumb) -replace '^Format-MessageStyle > ', '')]:"
            if ($MessageSettings.Indent) {
                $indent = " " * $MessageSettings.Indent
            }
            else {
                $indent = " " * 4
            }
        }
        elseif ($MessageSettings.FunctionName -and $Cmdlet) {
            $functionName = "[$($Cmdlet.MyInvocation.MyCommand.Name)] "
        }

        if ($MessageSettings.TimeStamp) {
            $timeStamp = "[$(Get-Date -Format "HH:mm:ss")] "
        }

        "{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message
    }
}
