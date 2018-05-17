function Remove-ServerConfiguration {
    <#
    .SYNOPSIS
        Remove a Stores Bitbucket Server from memory.

    .DESCRIPTION
        This function allows for several Bitbucket Server object to be removed in memory.

    .EXAMPLE
        Remove-BitbucketConfiguration -Name "Server Prod"
        -----------
        Description
        This command will remove the server identified as "Server Prod" from memory.

    .LINK
        Export-Configuration
    #>
    [CmdletBinding( SupportsShouldProcess = $false )]
    [OutputType( [AtlassianPS.ServerData] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Name with which this server is stored.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = "Get-Configuration"
                $module = (Get-command -Name $commandName).Module
                $commandName = $module.ExportedCommands.Keys | Where-Object {$_ -like ($command -replace "-", "-$($module.Prefix)")}
                & $commandName |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('ServerName', 'Alias')]
        [String[]]
        $Name,

        #
        [Switch]
        $Passthru
    )

    begin {
        Write-PSFMessage -Message "Function started" -Level Debug

        $serverList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        foreach ($server in ((Get-Configuration -Name Server).Value)) {
            if ($server.Name.ToLower() -notin $Name.ToLower()) {
                $null = $serverList.Add($server)
            }
            else {
                Write-PSFMessage -Message "Removing server [name = $($server.Name)]" -Level Verbose
            }
        }

        Set-Configuration -Name Server -Value $serverList

        if ($Passthru) {
            Write-Output $serverList
        }
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
