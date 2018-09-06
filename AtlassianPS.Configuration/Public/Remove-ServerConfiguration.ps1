function Remove-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
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
        [Alias('ServerName', 'Alias')]
        [String[]]
        $Name
    )

    begin {
        Write-Verbose "Function started"

        $serverList = Get-ServerConfiguration
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($serverToRemove in $Name) {
            if ($serverToRemove -notin $serverList.Name) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    ErrorId      = "AtlassianPS.ServerData.ServerNotFound"
                    Category     = "ObjectNotFound"
                    Message      = "No server '$serverToRemove' could be found."
                    TargetObject = $serverToRemove
                    Cmdlet       = $PSCmdlet
                }
                WriteError @writeErrorSplat
            }
        }

        $serverList = $serverList | Where-Object { $_.Name -notin $Name }
    }

    end {
        Write-DebugMessage "Persisting ServerList"
        $script:Configuration.ServerList = $serverList
        Save-Configuration

        Write-Verbose "Function ended"
    }
}
