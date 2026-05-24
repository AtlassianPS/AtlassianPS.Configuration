function Set-Configuration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
    [OutputType( [PSCustomObject] )]
    param(
        [Parameter( Mandatory, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = "Get-Configuration"
                $module = (Get-Command -Name $commandName).Module
                $commandName = $module.ExportedCommands.Keys | Where-Object { $_ -like ($command -replace "-", "-$($module.Prefix)") }
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

        $reservedNames = @('ServerList')
        $configurationChanged = $false
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Name -in $reservedNames) {
            $writeErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "Configuration key [$Name] is reserved and cannot be changed with Set-Configuration"
                ErrorId       = "AtlassianPS.Configuration.ReservedKey"
                Category      = "InvalidArgument"
                TargetObject  = $Name
            }
            WriteError @writeErrorSplat
            return
        }

        if ($Append) {
            Write-Verbose "Appending to existing value"
            $oldValue = (Get-Configuration -Name $Name -ValueOnly)
            if ($null -eq $oldValue) {
                $newValue = @($Value)
            }
            else {
                try {
                    $newValue = @(@($oldValue) + @($Value)) -as ($oldValue.GetType())
                    if (-not $newValue) {
                        throw "failed to cast to $($oldValue.GetType().Name)"
                    }
                }
                catch {
                    Write-DebugMessage $_

                    $newValue = @(@($oldValue) + @($Value))
                }
            }
            $Value = $newValue
        }

        if ($Value) { $dataType = $Value.GetType().Name }
        else { $dataType = "null" }
        Write-Verbose "Storing value [$dataType] to [name = $Name]"

        if ($PSCmdlet.ShouldProcess($Name, "Set configuration value")) {
            $script:Configuration.Remove($Name)
            $script:Configuration.Add($Name, $Value)
            $configurationChanged = $true

            if ($Passthru) {
                Get-Configuration -Name $Name
            }
        }
    }

    end {
        if ($configurationChanged) {
            Save-Configuration
        }

        Write-Verbose "Function ended"
    }
}
