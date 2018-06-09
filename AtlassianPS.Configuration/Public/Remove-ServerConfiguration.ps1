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
        #
        # Is case sensitive
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
        [String[]]
        $ServerName
    )

    begin {
        Write-Verbose "Function started"

        $serverList = Get-ServerConfiguration
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($serverToRemove in $ServerName) {
            if ($serverToRemove -notin $serverList.Name) {
                $exception = "Object Not Found"
                $errorId = "ServerType.ServerNotFound"
                $errorCategory = "ObjectNotFound"

                $writeErrorSplat = @{
                    Exception    = $exception
                    ErrorId      = $errorId
                    Category     = $errorCategory
                    Message      = "No server '$serverToRemove' could be found."
                    TargetObject = $serverToRemove
                    Cmdlet       = $PSCmdlet
                }
                WriteError @writeErrorSplat
            }

        }

        $serverList = $serverList | Where-Object { $_.Name -notin $ServerName }
    }

    end {
        $script:Configuration.ServerList = $serverList

        Write-Verbose "Function ended"
    }
}
