function Set-Configuration {
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage( 'PSUseShouldProcessForStateChangingFunctions', '' )]
    param(
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

        [Parameter( ValueFromPipelineByPropertyName )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Object]
        $Value,

        [Switch]
        $Append,

        [Switch]
        $Passthru
    )

    begin {
        Write-Verbose "Function started"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        If ($Append) {
            Write-Verbose "Appending to existing value"
            $oldValue = (Get-Configuration -Name $Name -ValueOnly)
            try {
                $newValue = @(@($oldValue) + @($Value)) -as ($oldValue.GetType())
                if (-not $newValue) {
                    throw "failed to case to $oldValue.GetType().Name"
                }
            }
            catch {
                Write-DebugMessage "Failed to use Type of previous value"

                $newValue = @(@($oldValue) + @($Value))
            }
            $Value = $newValue
        }

        if ($Value) { $dataType = $Value.GetType().Name }
        else { $dataType = "null" }
        Write-Verbose "Storing value [$dataType] to [name = $Name]"

        $script:Configuration.Remove($Name)
        $script:Configuration.Add($Name, $Value)
    }

    end {
        if ($Passthru) {
            Get-Configuration
        }

        Write-Verbose "Function ended"
    }
}
