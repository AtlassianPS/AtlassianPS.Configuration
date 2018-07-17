function Export-Configuration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"

        $data = Get-Configuration

        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = @{}
        foreach ($entry in $data) {
            $export[$entry.name] = $entry.value
        }

        $export["ServerList"] |
            Where-Object { $_.Session } |
            Foreach-Object { $_.Session = $null }

        ExportConfiguration -InputObject $export 3>$null

        Write-Verbose "Function ended"
    }
}
