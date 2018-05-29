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
    #>
    [CmdletBinding()]
    [OutputType()]
    param(
        # Name of the configuration to be retireved
        #
        # Allows wildcards
        [Parameter( ValueFromPipeline, ValueFromPipelineByPropertyName )]
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
        $Name = "*"
    )

    begin {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function started"

        $moduleName = $MyInvocation.MyCommand.ModuleName
    }

    process {
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$(Get-BreadCrumbs)]:"
        Write-DebugMessage "    PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_name in $Name) {
            Write-Verbose "[$(Get-BreadCrumbs)]:"
            Write-Verbose "    Filtering for [name = $_name]"
            $script:Configuration | Where-Object { $_.Name -like $_name }
        }
    }

    end {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function ended"
    }
}
