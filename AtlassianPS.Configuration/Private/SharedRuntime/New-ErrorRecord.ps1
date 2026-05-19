function New-ErrorRecord {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('ExistingException', 'NewException')]
        [String]
        $Mode,

        [Parameter()]
        [System.Exception]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExceptionType = 'System.Management.Automation.RuntimeException',

        [Parameter()]
        [String]
        $Message,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorCategory]
        $Category,

        [Parameter()]
        [Object]
        $TargetObject
    )

    if ($Mode -eq 'NewException') {
        if (-not $Message) {
            throw 'Message is required when creating a new exception.'
        }

        if ($Exception) {
            $Exception = New-Object -TypeName $ExceptionType -ArgumentList $Message, $Exception
        }
        else {
            $Exception = New-Object -TypeName $ExceptionType -ArgumentList $Message
        }
    }

    if (-not $Exception) {
        throw 'Exception is required when creating an error record from an existing exception.'
    }

    return [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $Category, $TargetObject)
}
