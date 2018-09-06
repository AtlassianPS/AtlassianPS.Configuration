function Save-Configuration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"

        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = Get-Configuration -AsHashtable
        $export["ServerList"] |
            Where-Object { $_.Session } |
            Foreach-Object { $_.Session = $null }

        ExportConfiguration -InputObject $export 3>$null

        Write-Verbose "Function ended"
    }
}
