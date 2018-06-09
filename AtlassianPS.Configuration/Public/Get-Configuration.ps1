function Get-Configuration {
    <#
    .SYNOPSIS
        Retireve a stored configuration

    .DESCRIPTION
        Retireve a stored configuration

    .EXAMPLE
        Get-AtlassianConfiguration
        --------
        Description
        Get all stored servers

    .EXAMPLE
        Get-AtlassianConfiguration -Key "Headers"
        --------
        Description
        Get configuration data in key "Headers"

    .LINK
        Set-Configuration

    .LINK
        Remove-Configuration
    #>
    [CmdletBinding()]
    [OutputType( [PSCustomObject] )]
    param(
        # Name of the configuration to be retireved
        #
        # Is not case sensitive
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

        # Indicates that this cmdlet gets only the value of the variable.
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
