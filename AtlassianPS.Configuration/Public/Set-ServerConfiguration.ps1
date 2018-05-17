function Set-ServerConfiguration {
    <#
    .SYNOPSIS
        Stores Bitbucket Server object for the module to known with what server it should talk to.

    .DESCRIPTION
        This function allows for several Bitbucket Server object to be stored in memory.
        Stored servers are used by the commands in order to know with what Bitbucket server to communicate.

        The stored servers can be exported to file with `Export-BitbucketConfiguration`.
        _Exported servers will be imported automatically when the module is loaded._

    .EXAMPLE
        Set-BitbucketConfiguration -Uri "https://server.com/" -Name "Server Prod"
        -----------
        Description
        This command will store the server address and name in memory and allow other commands
        to identify the server by the name "Server Prod"

    .LINK
        Export-Configuration
    #>
    [CmdletBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Address of the Bitbucket Server.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        # Name with which this server will be stored.
        # If no name is provided, the "Authority" of the addess will be used.
        # This value must be unique. In case the Name was already saved,
        # it will be overwritten.
        #
        # Example for "Authority":
        #   https://www.google.com/maps?hl=en --> "www.google.com"
        #
        # This property is not case sensitive
        [Parameter( ValueFromPipelineByPropertyName )]
        [ValidateScript(
            {
                if ("*" -in [char[]]$_) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]"Invalid Value of Parameter"),
                        'ParameterType.ContainsWildcard',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $_
                    )
                    $errorItem.ErrorDetails = "Name is not allowed to contain wildcards"
                    ThrowError $errorItem
                }
                else {
                    $true
                }
            }
        )]
        [Alias('ServerName', 'Alias')]
        [String]
        $Name = $Uri.Authority,

        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
        [AtlassianPS.ServerType]
        $Type,

        # Stores a WebSession to the server object.
        [Parameter( ValueFromPipelineByPropertyName )]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

        [Parameter( ValueFromPipelineByPropertyName )]
        [Hashtable]
        $Headers
    )

    begin {
        Write-PSFMessage -Message "Function started" -Level Debug
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        $serverList = Remove-ServerConfiguration -Name $Name -Passthru

        Write-PSFMessage -Message "Adding new entry [name = $Name]" -Level Verbose
        $serverList = @($serverList) + @([AtlassianPS.ServerData]@{
            Name    = $Name
            Uri     = $Uri
            Type    = $Type
            # IsCloudServer = (Test-ServerIsCloud -Type $Type -Uri $Uri -Headers $Headers -ErrorAction Stop -verbose)
            Session = $Session
            Headers = $Headers
        }) -as [AtlassianPS.ServerData[]]

        Write-PSFMessage -Message "Storing list with $($serverList.Count) entries" -Level Verbose
        Set-Configuration -Name Server -Value $serverList
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
