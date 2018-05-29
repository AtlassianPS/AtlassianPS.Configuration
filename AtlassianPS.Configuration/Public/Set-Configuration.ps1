function Set-Configuration {
    <#
    .SYNOPSIS
        Stores a key/value pair to the configuration

    .DESCRIPTION
        Stores a key/value pair to the configuration.
        This is only available in the current sessions, unless exported.

    .EXAMPLE
        Set-AtlassianConfiguration -Key "Headers" -Value @{Accept = "application/json"}
        -----------
        Description
        This command will store a new Header configuration

    .LINK
        Export-Configuration
    #>
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Name under which to store the value
        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
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
        [String]
        $Name,

        # Value to store
        [Parameter( ValueFromPipelineByPropertyName )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Object]
        $Value,

        [Parameter( ValueFromPipelineByPropertyName )]
        [AllowEmptyString()]
        [String]
        $Description,

        # Append Value to exisitng data
        [Switch]
        $Append,

        # Whether output should be provided after invoking this function
        [Switch]
        $Passthru
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

        If ($Append) {
            Write-Verbose "[$(Get-BreadCrumbs)]:"
            Write-Verbose "    Appending to existing value"
            $oldValue = (Get-Configuration -Name $Name).Value
            try {
                $Value = @(@($oldValue) + @($Value)) -as ($oldValue.GetType())
            }
            catch {
                Write-DebugMessage "[$(Get-BreadCrumbs)]:"
                Write-DebugMessage "    Failed to use Type of previous value"

                $Value = @(@($oldValue) + @($Value))
            }
        }

        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Storing value [$($Value.GetType().Name)] to [name = $Name]"
        $script:Configuration.Remove($Name)
        $script:Configuration.Add($Name, $Value)
    }

    end {
        if ($Passthru) {
            Write-DebugMessage "[$(Get-BreadCrumbs)]:"
            Write-DebugMessage "    Persisting Configuration"

            Write-Output $script:Configuration
        }

        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function ended"
    }
}
