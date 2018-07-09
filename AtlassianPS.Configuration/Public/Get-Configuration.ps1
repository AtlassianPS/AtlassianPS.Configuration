function Get-Configuration {
    [CmdletBinding()]
    [OutputType( [PSCustomObject] )]
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

        [Switch]
        $ValueOnly
    )

    begin {
        Write-Verbose "Function started"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_name in $Name) {
            foreach ($key in ($script:Configuration.Keys | Where-Object { $_ -like $_name })) {
                Write-Verbose "Filtering for [name = $key]"

                if ($ValueOnly) {
                    $script:Configuration[$key]
                }
                else {
                    [PSCustomObject]@{
                        Name  = $key
                        Value = $script:Configuration[$key]
                    }
                }
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
