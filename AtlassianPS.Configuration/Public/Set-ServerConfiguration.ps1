function Set-ServerConfiguration {
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        [Parameter( ValueFromPipelineByPropertyName )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName = $Uri.Authority,

        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
        [AtlassianPS.ServerType]
        $Type,

        [Parameter( ValueFromPipelineByPropertyName )]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

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
            Uri     = ([Uri]($Uri.AbsoluteUri -replace "\/$", ""))
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
