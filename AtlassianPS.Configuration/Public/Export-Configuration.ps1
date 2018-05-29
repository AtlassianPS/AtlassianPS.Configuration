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
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"
    }

    process {
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = $script:Configuration
        $export.ServerList = $export.ServerList | Select-Object -Exclude Session

        ExportConfiguration -InputObject $export
    }

    end {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function ended"
    }
}
