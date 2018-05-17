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
        Export-Configuration
    #>
    [CmdletBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Name under which the value is stored
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
        Write-PSFMessage -Message "Function started" -Level Debug

        $moduleName = $MyInvocation.MyCommand.ModuleName
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        foreach ($_name in $Name) {
            Write-PSFMessage -Message "Removing [name = $_name]" -Level Verbose
            Unregister-PSFConfig -Module $MyInvocation.MyCommand.ModuleName -Name $_name
            $null = [PSFramework.Configuration.ConfigurationHost]::Configurations.Remove("$($moduleName.ToLower()).$_name")
        }
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
