function Get-ServerConfiguration {
    <#
    .SYNOPSIS
        Get the data of a stored server.

    .DESCRIPTION
        Retrive the stored servers.

    .EXAMPLE
        Get-Configuration
        --------
        Description
        Get all stored servers

    .EXAMPLE
        Get-Configuration -name $Name "prod"
        --------
        Description
        Get the data of the server with name $Name "prod"

    .EXAMPLE
        Get-BitbucketConfiguration -Uri "https://myserver.com"
        --------
        Description
        Get the data of the server with address "https://myserver.com"
    #>
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.ServerData[]] )]
    param(
        # Address of the stored server.
        #
        # This parameter allows wildchards
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
        #
        # This parameter allows wildchards
        # This parameter is not case sensitive
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
        Write-PSFMessage -Message "Function started" -Level Debug

        Write-PSFMessage -Message "Fetching all" -Level Verbose
        $allServer = [AtlassianPS.ServerData[]]((Get-Configuration -Name "Server").Value)
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        switch ($PsCmdlet.ParameterSetName) {
            'ServerDataByName' {
                foreach ($_name in $Name) {
                    Write-PSFMessage -Message "Filtering for [Name = $_name]" -Level Verbose
                    $allServer | Where-Object { $_.Name -like $_name }
                }
            }
            'ServerDataByUri' {
                Write-PSFMessage -Message "Filtering for [Uri = $Uri]" -Level Verbose
                $allServer | Where-Object { $_.Uri -eq $Uri }
            }
            '_All' {
                $allServer
            }
        }
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
