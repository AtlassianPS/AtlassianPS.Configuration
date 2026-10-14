function Export-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][String]$Path, [String[]]$Name)

    $profiles = @(
        foreach ($server in @(Get-ServerConfiguration)) {
            if (-not $Name -or $server.Name -in $Name) { ConvertTo-PortableServer -Server $server }
        }
    )
    $document = @{ SchemaVersion = 1; ServerList = $profiles } | ConvertTo-Json -Depth 4
    if ($PSCmdlet.ShouldProcess($Path, 'Export non-secret server profiles')) {
        Set-Content -LiteralPath $Path -Value $document -Encoding UTF8
    }
}
