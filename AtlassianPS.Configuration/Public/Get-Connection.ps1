function Get-Connection {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType( [AtlassianPS.Connection] )]
    param(
        [String]
        $Product,

        [String]
        $Name,

        [Int]
        $Id,

        [Switch]
        $Default
    )

    Write-DebugMessage -BoundParameters $PSBoundParameters

    $script:Connections.Values | Where-Object {
        (-not $Product -or $_.Product -eq $Product) -and
        (-not $Name -or $_.Name -eq $Name) -and
        (-not $PSBoundParameters.ContainsKey('Id') -or $_.Id -eq $Id) -and
        (-not $Default -or $script:DefaultConnections[$_.Product] -eq $_.InstanceId)
    } | Sort-Object Id
}
