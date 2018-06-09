function Set-ServerConfiguration {
    <#
    .SYNOPSIS
        Stores Server object for the module to known with what server it should talk to.

    .DESCRIPTION
        This function allows for several Server object to be stored in memory.
        Stored servers are used by the commands in order to know with what server to communicate.

        The stored servers can be exported to file with `Export-AtlassianConfiguration`.
        _Exported servers will be imported automatically when the module is loaded._

    .EXAMPLE
        Set-AtlassianServerConfiguration -Uri "https://server.com/" -ServerName "Server Prod"
        -----------
        Description
        This command will store the server address and name in memory and allow other commands
        to identify the server by the name "Server Prod"

    .LINK
        Export-Configuration
    #>
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        # Address of the Server.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        # Name with which this server will be stored.
        # If no name is provided, the "Authority" of the addess will be used.
        # This value must be unique. In case the ServerName was already saved,
        # it will be overwritten.
        #
        # Example for "Authority":
        #   https://www.google.com/maps?hl=en --> "www.google.com"
        #
        # Is not case sensitive
        [Parameter( ValueFromPipelineByPropertyName )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName = $Uri.Authority,

        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
        [AtlassianPS.ServerType]
        $Type,

        # Stores a WebSession to the server object.
        [Parameter( ValueFromPipelineByPropertyName )]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

        # Stores the Headers that should be used for this server
        [Parameter( ValueFromPipelineByPropertyName )]
        [Hashtable]
        $Headers
    )

    begin {
        Write-Verbose "Function started"

        if (-not ($script:Configuration.ServerList)) {
            $script:Configuration.ServerList = $null
        }

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $config = [AtlassianPS.ServerData]@{
            Name    = $ServerName
            Uri     = $Uri
            Type    = $Type
            # IsCloudServer = (Test-ServerIsCloud -Type $Type -Uri $Uri -Headers $Headers -ErrorAction Stop -verbose)
            Session = $Session
            Headers = $Headers
        }

        foreach ($server in $script:Configuration.ServerList) {
            if ($server.Name -ne $config.Name) {
                $serverList.Add($server)
            }
            else {
                Write-DebugMessage "Removing server `$server: $($server.Name)"
            }
        }

        Write-DebugMessage "Adding server `$config: $($config.Name)" -BreakPoint
        $serverList.Add($config)
    }

    end {
        Write-DebugMessage "Persisting ServerList"
        $script:Configuration.ServerList = $serverList

        Write-Verbose "Function ended"
    }
}
