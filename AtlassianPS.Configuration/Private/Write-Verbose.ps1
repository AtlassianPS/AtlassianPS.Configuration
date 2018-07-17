function Write-Verbose {
    <#
    .SYNOPSIS
        Write a verbose message

    .DESCRIPTION
        Write a verbose message

        This function allows the user to decide how the Verbose Message
        should be formatted. The configuration is inside `$scrpit:Configuration`
        and supports the following structure (json representation):

        {
            "message": {
                "style": {
                    // show a line with the Bread Crumbs of the caller stack
                    "breadcrumbs": true,

                    // how many whitespaces should be used for indenting the
                    // message
                    "indent": true,

                    // show the name of the calling function - this is ignored
                    // if breadcrumbs is active
                    "functionname": true,

                    // show the timestamp (HH:mm:ss format) of the message
                    "timestamp": true
                }
            }
        }

    .EXAMPLE
        Write-DebugMessage "The value of `$var is: $var"
        ----------
        Description
        Shows the message if the user added `-Debug` to the command but does not create a breakpoint
    #>
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [String]
        $Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = ((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    begin {
        $indent, $functionName, $timeStamp = ""

        Import-MqcnAlias -Alias "WriteVerbose" -Command "Microsoft.PowerShell.Utility\Write-Verbose"

        $messageSettings = $script:Configuration["Message"]
    }

    process {

        if ((Get-PSCallstack | Select-Object -Last 1 -Skip 1).Arguments.Contains("Verbose")) {
            $VerbosePreference = 'Continue'
        }

        if ($messageSettings["Breadcrumbs"]) {
            WriteVerbose "[$(Get-BreadCrumb)]:"

            if ($messageSettings["Indent"]) {
                $indent = " " * $messageSettings["Indent"]
            }
            else {
                $indent = " " * 4
            }
        }
        else {
            if ($messageSettings["FunctionName"]) {
                $functionName = "[$($Cmdlet.MyInvocation.MyCommand.Name)] "
            }
        }

        if ($messageSettings["Timestamp"]) {
            $timeStamp = "[$(Get-Date -f "HH:mm:ss")] "
        }

        WriteVerbose ("{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message)
    }
}
