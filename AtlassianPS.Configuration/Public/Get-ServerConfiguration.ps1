function Get-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.ServerData] )]
    param(
        [Parameter( Position = 0, Mandatory, ParameterSetName = 'ServerDataByUri' )]
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

        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ServerDataByName' )]
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
        Write-Verbose "Function started"

        $serverList = Get-Configuration -Name ServerList -ValueOnly
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdlet.ParameterSetName) {
            'ServerDataByName' {
                Write-Verbose "Filtering ServerList for [Name = $Name]"

                $serverList | Where-Object { $_.Name -in $Name }
            }
            'ServerDataByUri' {
                Write-Verbose "Filtering ServerList for [URI = $Uri]"

                $serverList | Where-Object { $_.Uri -like $Uri }
            }
            '_All' {
                $serverList
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
