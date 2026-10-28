function Register-Connection {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType( [AtlassianPS.Connection] )]
    param(
        [Parameter( Mandatory )]
        [AtlassianPS.Connection]
        $Connection,

        [Switch]
        $Default
    )

    Write-DebugMessage -BoundParameters $PSBoundParameters

    if ($Connection.RegistryGeneration -ne $script:RegistryGeneration -or $Connection.State -ne 'Candidate') {
        throw 'Only a candidate from this runtime can be registered.'
    }
    if (-not $Connection.DeploymentType) { throw 'Validate the product endpoint and identity before registration.' }
    if (Get-Connection -Product $Connection.Product -Name $Connection.Name) { throw 'A connection with that product and name already exists.' }

    $script:NextConnectionId++
    $Connection.Register($script:NextConnectionId)
    $script:Connections[$Connection.InstanceId] = $Connection

    if ($Default -or -not $script:DefaultConnections.ContainsKey($Connection.Product)) {
        $script:DefaultConnections[$Connection.Product] = $Connection.InstanceId
    }

    $Connection
}
