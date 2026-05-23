function Add-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType( [void] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [ValidateScript( { $_.IsAbsoluteUri } )]
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
        $Headers
    )

    begin {
        Write-Verbose "Function started"

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
        foreach ($server in @(Get-ServerConfiguration)) {
            $serverList.Add($server)
        }
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $entryName = if ($PSBoundParameters.ContainsKey('Name')) { $Name } else { $Uri.Authority }
        $entryHeaders = if ($PSBoundParameters.ContainsKey('Headers')) { $Headers } else { @{} }

        if ($serverList | Where-Object Name -eq $entryName) {
            $writeErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "An entry with name [$entryName] already exists"
                ErrorId       = "AtlassianPS.ServerData.EntryExists"
                Category      = "InvalidData"
                TargetObject  = $entryName
            }
            WriteError @writeErrorSplat
        }
        else {
            if (-not ($index = ($serverList.Id | Measure-Object -Maximum).Maximum)) {
                $index = 0
            }
            $index++

            $config = [AtlassianPS.ServerData]@{
                Id      = $index
                Name    = $entryName
                Uri     = ([Uri]($Uri.AbsoluteUri -replace "\/$", ""))
                Type    = $Type
                # IsCloudServer = (Test-ServerIsCloud -Type $Type -Uri $Uri -Headers $Headers -ErrorAction Stop -verbose)
                Session = $Session
                Headers = $entryHeaders
            }

            Write-Verbose "Adding server #$($index): [$($config.Name)]"
            Write-DebugMessage "Adding server `$config: $($config.Name) @ index $index" -BreakPoint
            $serverList.Add($config)
        }
    }

    end {
        Write-DebugMessage "Persisting ServerList"
        $script:Configuration["ServerList"] = $serverList
        Save-Configuration

        Write-Verbose "Function ended"
    }
}
