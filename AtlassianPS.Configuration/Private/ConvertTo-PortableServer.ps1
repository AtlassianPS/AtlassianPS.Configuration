function ConvertTo-PortableServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AtlassianPS.ServerData]$Server
    )

    if ($Server.Certificate -or ($Server.Headers -and $Server.Headers.Count -gt 0)) {
        throw 'Legacy profile contains headers or a certificate. Remove those settings and supply authentication to Connect before saving or exporting.'
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
