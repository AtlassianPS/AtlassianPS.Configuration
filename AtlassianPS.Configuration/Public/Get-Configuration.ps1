function Get-Configuration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( DefaultParameterSetName = 'asObject' )]
    [OutputType( [PSCustomObject], ParameterSetName = 'asObject' )]
    [OutputType( [PSObject], ParameterSetName = 'asValue' )]
    [OutputType( [Hashtable], ParameterSetName = 'asHashTable' )]
    param(
        [Parameter( ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
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
        [String[]]
        $Name = '*',

        [Parameter( Mandatory, ParameterSetName = 'asValue' )]
        [Switch]
        $ValueOnly,

        [Parameter( Mandatory, ParameterSetName = 'asHashtable' )]
        [Switch]
        $AsHashtable
    )

    begin {
        Write-Verbose "Function started"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $data = @{}

        foreach ($_name in $Name) {
            foreach ($key in ($script:Configuration.Keys | Where-Object { $_ -like $_name })) {
                Write-Verbose "Filtering for [name = $key]"

                $data[$key] = $script:Configuration[$key]
            }
        }

        if ($AsHashtable) { $data }
        elseif ($ValueOnly) { $data.Values }
        else {
            foreach ($key in $data.Keys) {
                New-Object -TypeName PSCustomObject -Property @{ Name = $key; Value = $data[$key] }
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
