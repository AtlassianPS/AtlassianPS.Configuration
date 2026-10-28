function Assert-ConnectionActive {
    <#
    .SYNOPSIS
        Validates a connection against the current runtime registry.

    .DESCRIPTION
        Requires an active registration from the current runtime generation.
        Temporary authentication overrides are checked against their source connection.
        Throws when the connection is disconnected, unregistered or belongs to another requested product.

    .PARAMETER Connection
        Registered connection or temporary override to validate.

    .PARAMETER Product
        Expected product name when product matching is required.

    .PARAMETER RegisteredOnly
        Requires the supplied connection itself to be active, excluding temporary overrides.

    .EXAMPLE
        Assert-ConnectionActive -Connection $connection -Product Jira -RegisteredOnly

        Validates an active Jira registration before changing its default selection.

    .OUTPUTS
        None.
    #>
    [CmdletBinding()]
    param(
        [Parameter( Mandatory )]
        [AtlassianPS.Connection]
        $Connection,

        [String]
        $Product,

        [Switch]
        $RegisteredOnly
    )

    $sourceId = if ($Connection.IsOverride) { $Connection.SourceInstanceId }
    else { $Connection.InstanceId }
    $registered = $script:Connections[$sourceId]

    if ($Connection.RegistryGeneration -ne $script:RegistryGeneration -or
        ($RegisteredOnly -and $Connection.State -ne 'Active') -or
        $Connection.State -eq 'Disconnected' -or -not $registered -or
        $registered.State -ne 'Active' -or
        (-not $Connection.IsOverride -and -not [Object]::ReferenceEquals($registered, $Connection))
    ) {
        throw 'Connection is not active in this runtime. Connect again in this PowerShell session.'
    }

    if ($Product -and $Connection.Product -ne $Product) { throw "Connection belongs to another product; expected $Product." }
}
