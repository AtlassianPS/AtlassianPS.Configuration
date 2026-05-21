function Resolve-FullPath {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                if (-not (Test-Path $_ -PathType Leaf)) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]'File not found'),
                        'ParameterValue.FileNotFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $_
                    )
                    $errorItem.ErrorDetails = "No file could be found with the provided path '$_'."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
                else {
                    return $true
                }
            }
        )]
        [Alias('FullName', 'PSPath')]
        [String]
        $Path
    )

    process {
        $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
    }
}
