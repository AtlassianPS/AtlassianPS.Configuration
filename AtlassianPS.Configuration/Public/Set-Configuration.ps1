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
    [CmdletBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
        # Name under which to store the value
        #
        # This property is not case sensitive
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

        $moduleName = $MyInvocation.MyCommand.ModuleName
    }

    process {
        Write-PSFMessage -Message "ParameterSetName: $($PsCmdlet.ParameterSetName)" -Level Debug
        Write-PSFMessage -Message "PSBoundParameters: $($PSBoundParameters | Out-String)" -Level Debug

        If ($Append) {
            Write-PSFMessage -Message "Appending to existing value" -Level Verbose
            $oldValue = (Get-Configuration -Name $Name).Value
            try {
                $Value = @(@($oldValue) + @($Value)) -as ($oldValue.GetType())
            }
            catch {
                Write-PSFMessage -Message "Failed to use Type of previous value" -Level Debug
                $Value = @(@($oldValue) + @($Value))
            }
        }

        Write-PSFMessage -Message "Storing value [$($Value.GetType().Name)] to [name = $Name]" -Level Verbose
        Set-PSFConfig -Module AtlassianPS.Configuration -Name $Name -Value $Value -Description $Description
        Register-PSFConfig -FullName "$($moduleName.ToLower()).$Name"

        if ($Passthru) {
            Write-Output $Value
        }
    }

    end {
        Write-Verbose "[$(Get-BreadCrumbs)]:"
        Write-Verbose "    Function ended"
    }
}
