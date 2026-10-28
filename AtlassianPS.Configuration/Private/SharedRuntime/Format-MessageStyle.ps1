function Format-MessageStyle {
    <#
    .SYNOPSIS
        Applies the configured style to a diagnostic message.

    .DESCRIPTION
        Formats message text with optional timestamps, caller names or breadcrumbs.
        Breadcrumbs produce a separate header and take precedence over function-name prefixes.
        Breadcrumb indentation defaults to four spaces when no nonzero indent is configured.
        This helper returns text; the calling writer chooses the output stream.

    .PARAMETER Message
        Message text to format, including empty strings and pipeline input.

    .PARAMETER Cmdlet
        Caller context used for the function-name prefix when enabled.

    .PARAMETER MessageSettings
        Message style to apply.
        Defaults to the configured Message setting, or a new MessageStyle when that setting is absent.

    .EXAMPLE
        Format-MessageStyle -Message 'Request completed.' -Cmdlet $PSCmdlet

        Formats a message using the caller context and current message settings.

    .INPUTS
        System.String

    .OUTPUTS
        System.String
    #>
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
            $breadCrumb = (Get-BreadCrumb) -replace '^(?:(?:Format-MessageStyle|Write-DebugMessage|Write-VerboseMessage) > )+', ''
            "[$breadCrumb]:"
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
