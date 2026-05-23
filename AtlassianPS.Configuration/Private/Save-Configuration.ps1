function Save-Configuration {
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"

        $configuration = Get-Configuration -AsHashtable
        $export = @{}
        foreach ($key in $configuration.Keys) {
            $export[$key] = $configuration[$key]
        }

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
        foreach ($server in @($export["ServerList"])) {
            if (-not $server) { continue }

            $serverData = [AtlassianPS.ServerData]@{
                Id          = $server.Id
                Name        = $server.Name
                Uri         = $server.Uri
                Type        = $server.Type
                Certificate = $server.Certificate
                Headers     = if ($server.Headers) { $server.Headers.Clone() } else { $null }
            }
            $serverList.Add($serverData)
        }
        $export["ServerList"] = $serverList

        ExportConfiguration -InputObject $export 3>$null

        Write-Verbose "Function ended"
    }
}
