function Export-Configuration {
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = Get-Configuration
        $export.ServerList |
            Where-Object { $_.Session } |
            Foreach-Object { $_.Session = $null }

        ExportConfiguration -InputObject $export
    }

    end {
        Write-Verbose "Function ended"
    }
}
