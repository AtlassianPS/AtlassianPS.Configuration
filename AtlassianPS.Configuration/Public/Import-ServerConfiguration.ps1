function Import-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][String]$Path, [Switch]$Replace)

    $document = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    if ($document.SchemaVersion -ne 1 -or -not $document.PSObject.Properties['ServerList'] -or
        @($document.PSObject.Properties.Name | Where-Object { $_ -notin @('SchemaVersion', 'ServerList') }).Count) {
        throw 'Unsupported profile document. Expected SchemaVersion 1 and ServerList.'
    }
    $newList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
    foreach ($server in @(Get-ServerConfiguration)) { $newList.Add($server) }
    $names = @{}
    foreach ($entry in @($document.ServerList)) {
        if (-not $entry -or @($entry.PSObject.Properties.Name | Where-Object { $_ -notin @('Id', 'Name', 'Uri', 'Type') }).Count -or
            [string]::IsNullOrWhiteSpace($entry.Name) -or $names.ContainsKey($entry.Name)) {
            throw 'Invalid profile fields or duplicate profile names.'
        }
        $names[$entry.Name] = $true
        $server = [AtlassianPS.ServerData]@{ Id = 1; Name = $entry.Name; Uri = $entry.Uri; Type = $entry.Type }
        $null = ConvertTo-PortableServer -Server $server
        $existing = @($newList | Where-Object Name -eq $server.Name)
        if ($existing.Count -and -not $Replace) { throw 'A profile with that name exists. Use Replace to replace it.' }
        foreach ($item in $existing) { $null = $newList.Remove($item) }
        $server.Id = 1 + [int](($newList.Id | Measure-Object -Maximum).Maximum)
        $newList.Add($server)
    }
    if ($PSCmdlet.ShouldProcess($Path, 'Import validated non-secret server profiles')) {
        $previous = $script:Configuration['ServerList']
        try {
            $script:Configuration['ServerList'] = $newList
            Save-Configuration -ErrorAction Stop
        }
        catch {
            $script:Configuration['ServerList'] = $previous
            throw
        }
    }
}
