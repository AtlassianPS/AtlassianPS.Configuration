function Disconnect-Connection {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'Object' )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'Object' )]
        [AtlassianPS.Connection]
        $Connection,

        [Parameter( Mandatory, ParameterSetName = 'Name' )]
        [String]
        $Name,

        [Parameter( Mandatory, ParameterSetName = 'Name' )]
        [String]
        $Product,

        [Parameter( Mandatory, ParameterSetName = 'Id' )]
        [Int]
        $Id
    )

    process {
        Write-DebugMessage -BoundParameters $PSBoundParameters

        if ($PSCmdlet.ParameterSetName -ne 'Object') {
            $filter = @{}
            foreach ($key in @('Product', 'Name', 'Id')) {
                if ($PSBoundParameters.ContainsKey($key)) { $filter[$key] = $PSBoundParameters[$key] }
            }

            $Connection = Get-Connection @filter
        }

        if (-not $Connection) { throw 'Connection not found.' }
        Assert-ConnectionActive -Connection $Connection -RegisteredOnly

        if ($PSCmdlet.ShouldProcess($Connection.ToString(), 'Disconnect')) {
            $script:Connections.Remove($Connection.InstanceId)
            if ($script:DefaultConnections[$Connection.Product] -eq $Connection.InstanceId) {
                $script:DefaultConnections.Remove($Connection.Product)
            }

            $Connection.Dispose()
        }
    }
}
