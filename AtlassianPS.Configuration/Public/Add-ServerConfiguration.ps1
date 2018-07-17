function Add-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        [Parameter( ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [Alias('ServerName', 'Alias')]
        [String]
        $Name,

        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
        [AtlassianPS.ServerType]
        $Type,

        [Parameter( ValueFromPipelineByPropertyName )]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

        [Parameter( ValueFromPipelineByPropertyName )]
        [Hashtable]
        $Headers = @{}
    )

    begin {
        Write-Verbose "Function started"

        if (-not ($script:Configuration.ServerList)) {
            $script:Configuration.ServerList = $null
        }

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
        if (Get-ServerConfiguration) {
            [System.Collections.Generic.List[AtlassianPS.ServerData]]$serverList = Get-ServerConfiguration
        }
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        if (-not $Name) {
            $Name = $Uri.Authority
        }

        if (Get-ServerConfiguration | Where-Object Name -eq $Name) {
            $writeErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "An entry with name [$Name] already exists"
                ErrorId       = "AtlassianPS.ServerData.EntryExists"
                Category      = "InvalidData"
                TargetObject  = $Name
            }
            WriteError @writeErrorSplat
        }
        else {
            if (-not ($index = ((Get-ServerConfiguration).Id | Measure-Object -Maximum).Maximum)) {
                $index = 0
            }
            $index++

            $config = [AtlassianPS.ServerData]@{
                Id      = $index
                Name    = $Name
                Uri     = ([Uri]($Uri.AbsoluteUri -replace "\/$", ""))
                Type    = $Type
                # IsCloudServer = (Test-ServerIsCloud -Type $Type -Uri $Uri -Headers $Headers -ErrorAction Stop -verbose)
                Session = $Session
                Headers = $Headers
            }

            Write-Verbose "Adding server #$($index): [$($config.Name)]"
            Write-DebugMessage "Adding server `$config: $($config.Name) @ index $index" -BreakPoint
            $serverList.Add($config)
        }
    }

    end {
        Write-DebugMessage "Persisting ServerList"
        $script:Configuration["ServerList"] = $serverList

        Write-Verbose "Function ended"
    }
}
