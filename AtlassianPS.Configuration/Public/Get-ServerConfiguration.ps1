function Get-ServerConfiguration {
    <#
    .SYNOPSIS
        Get the data of a stored server.

    .DESCRIPTION
        Retrive the stored servers.

    .EXAMPLE
        Get-AtlassianServerConfiguration
        --------
        Description
        Get all stored servers

    .EXAMPLE
        Get-AtlassianServerConfiguration -name $Name "prod"
        --------
        Description
        Get the data of the server with name $Name "prod"

    .EXAMPLE
        Get-AtlassianServerConfiguration -Uri "https://myserver.com"
        --------
        Description
        Get the data of the server with address "https://myserver.com"

    .LINK
        Set-ServerConfiguration

    .LINK
        Remove-ServerConfiguration
    #>
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.ServerData] )]
    param(
        # Address of the stored server.
        [Parameter( Mandatory, ParameterSetName = 'ServerDataByUri' )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = "Get-ServerConfiguration"
                $module = (Get-command -Name $commandName).Module
                $commandName = $module.ExportedCommands.Keys | Where-Object {$_ -like ($command -replace "-", "-$($module.Prefix)")}
                & $commandName |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        # Name of the server that was defined when stored.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ServerDataByName' )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = "Get-ServerConfiguration"
                $module = (Get-command -Name $commandName).Module
                $commandName = $module.ExportedCommands.Keys | Where-Object {$_ -like ($command -replace "-", "-$($module.Prefix)")}
                & $commandName |
                    Where-Object { $_.Uri -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('ServerName', 'Alias')]
        [String[]]
        $Name
    )

    begin {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function started"
    }

    process {
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdlet.ParameterSetName) {
            'ServerDataByName' {
                Write-Verbose "[$(Get-BreadCrumbs)]:"
                Write-Verbose "    Filtering for [Name = $ServerName]"

                Write-Ouput ($script:Configuration.ServerList | Where-Object { $_.Name -eq $ServerName })
            }
            'ServerDataByUri' {
                Write-Verbose "[$(Get-BreadCrumbs)]:"
                Write-Verbose "    Filtering for [URI = $Uri]"

                Write-Ouput ($script:Configuration.ServerList | Where-Object { $_.Uri -eq $Uri })
            }
            'ServerData' {
                Write-Ouput ($script:Configuration.ServerList)
            }
        }
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
