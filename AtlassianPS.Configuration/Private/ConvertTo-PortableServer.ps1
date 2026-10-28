function ConvertTo-PortableServer {
    <#
    .SYNOPSIS
        Projects a server profile into a portable dictionary.

    .DESCRIPTION
        Returns only Id, Name, Uri and Type without changing the supplied server.
        Rejects headers, certificates and URIs that are relative or contain user information, queries or fragments.
        Session and other authentication fields are omitted from the returned dictionary.

    .PARAMETER Server
        Server profile to validate and project for portable export.

    .EXAMPLE
        $profile = ConvertTo-PortableServer -Server $server

        Creates the approved profile fields for JSON serialization.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
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
