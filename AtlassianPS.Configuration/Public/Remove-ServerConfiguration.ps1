function Remove-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
    [OutputType( [void] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $commandName = (Get-Command -Module "AtlassianPS.Configuration" -Name "Get-*ServerConfiguration").Name
                & $commandName |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('ServerName', 'Alias')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Name
    )

    begin {
        Write-Verbose "Function started"

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
        foreach ($server in @(Get-ServerConfiguration)) {
            $serverList.Add($server)
        }

        $configurationChanged = $false
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($serverToRemove in $Name) {
            if ($serverToRemove -notin $serverList.Name) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    ErrorId       = "AtlassianPS.ServerData.ServerNotFound"
                    Category      = "ObjectNotFound"
                    Message       = "No server '$serverToRemove' could be found."
                    TargetObject  = $serverToRemove
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
            }
        }

        foreach ($serverToRemove in $Name) {
            if ($serverToRemove -in $serverList.Name -and $PSCmdlet.ShouldProcess($serverToRemove, "Remove server configuration")) {
                $remainingServers = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
                foreach ($server in $serverList) {
                    if ($server.Name -ne $serverToRemove) {
                        $remainingServers.Add($server)
                    }
                }
                $serverList = $remainingServers
                $configurationChanged = $true
            }
        }
    }

    end {
        if ($configurationChanged) {
            Write-DebugMessage "Persisting ServerList"
            $script:Configuration.Remove("ServerList")
            $script:Configuration.Add("ServerList", $serverList)
            Save-Configuration
        }

        Write-Verbose "Function ended"
    }
}
