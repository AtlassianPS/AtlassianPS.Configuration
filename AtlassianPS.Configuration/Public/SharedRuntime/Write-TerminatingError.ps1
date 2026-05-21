function Write-TerminatingError {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName = 'ExistingException')]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $PSCmdlet,

        [Parameter(Mandatory, ParameterSetName = 'ExistingException', Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'NewException')]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception,

        [Parameter(ParameterSetName = 'NewException', Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExceptionType = 'System.Management.Automation.RuntimeException',

        [Parameter(Mandatory, ParameterSetName = 'NewException', Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter()]
        [Object]
        $TargetObject,

        [Parameter(Mandatory, ParameterSetName = 'ExistingException', Position = 10)]
        [Parameter(Mandatory, ParameterSetName = 'NewException', Position = 10)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ErrorId,

        [Parameter(Mandatory, ParameterSetName = 'ExistingException', Position = 11)]
        [Parameter(Mandatory, ParameterSetName = 'NewException', Position = 11)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorCategory]
        $Category,

        [Parameter(Mandatory, ParameterSetName = 'Rethrow', Position = 1)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    process {
        if (-not $Cmdlet) {
            throw 'Cmdlet runtime was not provided. Call this helper from an advanced function or pass -Cmdlet.'
        }

        if (-not $ErrorRecord) {
            $mode = if ($PSCmdlet.ParameterSetName -eq 'NewException') {
                'NewException'
            }
            else {
                'ExistingException'
            }

            $ErrorRecord = New-ErrorRecord `
                -Mode $mode `
                -Exception $Exception `
                -ExceptionType $ExceptionType `
                -Message $Message `
                -ErrorId $ErrorId `
                -Category $Category `
                -TargetObject $TargetObject
        }

        $Cmdlet.ThrowTerminatingError($ErrorRecord)
    }
}
