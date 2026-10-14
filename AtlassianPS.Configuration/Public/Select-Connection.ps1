function Select-Connection {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding(DefaultParameterSetName = 'Object')]
    [OutputType([AtlassianPS.Connection])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Object')][AtlassianPS.Connection]$Connection,
        [Parameter(Mandatory, ParameterSetName = 'Name')][String]$Name,
        [Parameter(Mandatory, ParameterSetName = 'Name')][String]$Product,
        [Parameter(Mandatory, ParameterSetName = 'Id')][Int]$Id
    )
    process {
        if ($PSCmdlet.ParameterSetName -ne 'Object') {
            $filter = @{}
            foreach ($key in @('Product', 'Name', 'Id')) {
                if ($PSBoundParameters.ContainsKey($key)) { $filter[$key] = $PSBoundParameters[$key] }
            }
            $Connection = Get-Connection @filter
        }
        if (-not $Connection) { throw 'Connection not found.' }
        Assert-ConnectionActive -Connection $Connection -RegisteredOnly
        $script:DefaultConnections[$Connection.Product] = $Connection.InstanceId
        $Connection
    }
}
