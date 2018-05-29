function Remove-ServerConfiguration {
    <#
    .SYNOPSIS
        Remove a Stores Server from memory.

    .DESCRIPTION
        This function allows for several Server object to be removed in memory.

    .EXAMPLE
        Remove-AtlassianServerConfiguration -ServerName "Server Prod"
        -----------
        Description
        This command will remove the server identified as "Server Prod" from memory.

    .LINK
        Get-ServerConfiguration

    .LINK
        Set-ServerConfiguration
    #>
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        # Name with which this server is stored.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $commandName = (Get-Command -Module "AtlassianPS.Configuration" -Name "Get-*ServerConfiguration").Name
                & $commandName |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName
    )

    begin {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function started"

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
    }

    process {
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    PSBoundParameters: $($PSBoundParameters | Out-String)"

        $trackRemoval = 0
        foreach ($server in $script:Configuration.Server) {
            if ($server.Name -ne $ServerName) {
                $newConfiguration.Add($server)
            }
            else {
                Write-DebugMessage "[$(Get-BreadCrumbs)]:"
                Write-Debug "    ParameterSetName: $($PsCmdlet.ParameterSetName)"

                $trackRemoval++
            }
        }
    }

    end {
        if ($trackRemoval.Count) {
            Write-DebugMessage "[$(Get-BreadCrumbs)]:"
            Write-DebugMessage "    Persisting ServerList"

            $script:Configuration.ServerList = $serverList
        }
        else {
            $errorItem = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]"Object Not Found"),
                "ServerType.UnknownType",
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $ServerName
            )
            $errorItem.ErrorDetails = "No server '$ServerName' could be found."
            WriteError $errorItem
        }

        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function ended"
    }
}
