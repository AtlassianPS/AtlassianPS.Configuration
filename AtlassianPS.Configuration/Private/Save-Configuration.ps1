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

            $profileUri = [UriBuilder]::new($server.Uri)
            $profileUri.UserName = ''
            $profileUri.Password = ''
            $profileUri.Query = ''
            $profileUri.Fragment = ''

            $profile = [AtlassianPS.ServerData]@{
                Id   = $server.Id
                Name = $server.Name
                Uri  = $profileUri.Uri
                Type = $server.Type
            }
            $portable = ConvertTo-PortableServer -Server $profile
            $serverData = [AtlassianPS.ServerData]$portable
            $serverList.Add($serverData)
        }
        $export["ServerList"] = $serverList

        ExportConfiguration -InputObject $export -ErrorAction Stop 3>$null

        Write-Verbose "Function ended"
    }
}
