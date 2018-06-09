function Remove-Configuration {
    <#
    .SYNOPSIS
        Remove a configuration entry.

    .DESCRIPTION
        Remove a configuration entry.

    .EXAMPLE
        Remove-AtlassianConfiguration -Name "Headers"
        -----------
        Description
        This command will remove "Headers" configuration.

    .LINK
        Set-Configuration
    #>
    [CmdletBinding( ConfirmImpact = 'Low' ,SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Name under which the value is stored
        #
        # Is not case sensitive
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
        [String[]]
        $Name
    )

    begin {
        Write-Verbose "Function started"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_name in $Name) {
            Write-Verbose "Filtering for [name = $_name]"

            $script:Configuration.Remove($_name)
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
