function ConvertTo-PortableServer {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory )]
        [AtlassianPS.ServerData]
        $Server
    )

    if ($Server.Certificate -or ($Server.Headers -and $Server.Headers.Count -gt 0)) {
        throw 'Profiles cannot contain headers or certificates. Supply authentication when connecting.'
    }
    if (-not $Server.Uri.IsAbsoluteUri -or $Server.Uri.UserInfo -or $Server.Uri.Query -or $Server.Uri.Fragment) {
        throw 'Profile URI must be absolute and contain no user information, query or fragment.'
    }
    [ordered]@{
        Id   = $Server.Id
        Name = $Server.Name
        Uri  = $Server.Uri.AbsoluteUri
        Type = $Server.Type.ToString()
    }
}
