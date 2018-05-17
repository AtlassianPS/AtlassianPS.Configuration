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
        Write-PSFMessage -Message "Function started" -Level Debug

        $moduleName = $MyInvocation.MyCommand.ModuleName

        Write-PSFMessage -Message "Fetching all" -Level Verbose
        $configuration = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        foreach ($_name in $Name) {
            Write-PSFMessage -Message "Filtering for [name = $_name]" -Level Verbose
            $configuration |
                Where-Object { ($_.Module -eq $moduleName.ToLower()) -and ($_.Name -like $_name) -and (-not $_.Hidden) } |
                Select-Object Name, Value, Description
        }
    }

    end {
        Write-PSFMessage -Message "Function ended" -Level Debug
    }
}
