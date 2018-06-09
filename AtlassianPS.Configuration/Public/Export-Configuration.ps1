function Export-Configuration {
    <#
    .SYNOPSIS
        Store the server configuration to disk

    .DESCRIPTION
        This allows to store the Bitbucket Servers stored in the module's memory to disk.
        By doing this, the module will load the servers back into memory every time it is loaded.

        _Stored sessions will not be stored when exported._

    .EXAMPLE
        Set-AtlassianServerConfiguration -Uri "https://server.com"
        Export-AtlassianConfiguration
        --------
        Description
        Stores the server to disk.

    .LINK
        Set-Configuration

    .LINK
        JiraPS\New-Session
    #>
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = Get-Configuration
        $export.ServerList | Foreach-Object { $_.Session = $null }

        ExportConfiguration -InputObject $export
    }

    end {
        Write-Verbose "Function ended"
    }
}
