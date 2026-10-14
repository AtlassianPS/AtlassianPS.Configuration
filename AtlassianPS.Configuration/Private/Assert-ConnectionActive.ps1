function Assert-ConnectionActive {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AtlassianPS.Connection]$Connection, [String]$Product, [Switch]$RegisteredOnly)

    $sourceId = if ($Connection.IsOverride) { $Connection.SourceInstanceId } else { $Connection.InstanceId }
    $registered = $script:Connections[$sourceId]
    if ($Connection.RegistryGeneration -ne $script:RegistryGeneration -or
        ($RegisteredOnly -and $Connection.State -ne 'Active') -or
        $Connection.State -eq 'Disconnected' -or -not $registered -or
        $registered.State -ne 'Active' -or
        (-not $Connection.IsOverride -and -not [Object]::ReferenceEquals($registered, $Connection))) {
        throw 'Connection is not active in this runtime. Connect again in this PowerShell session.'
    }
    if ($Product -and $Connection.Product -ne $Product) { throw "Connection belongs to another product; expected $Product." }
}
