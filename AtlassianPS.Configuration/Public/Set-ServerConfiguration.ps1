function Set-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [OutputType( [void] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [UInt32]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('ServerName', 'Alias')]
        [String]
        $Name = $Uri.Authority,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.ServerType]
        $Type,

        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

        [Parameter()]
        [Hashtable]
        $Headers
    )

    begin {
        Write-Verbose "Function started"

        $parametersToIgnore = @(
            'Id'
            'Verbose'
            'Debug'
            'ErrorAction'
            'WarningAction'
            'InformationAction'
            'ErrorVariable'
            'WarningVariable'
            'InformationVariable'
            'OutVariable'
            'OutBuffer'
            'PipelineVariable'
            'WhatIf'
            'Confirm'
        )
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $serverEntry = Get-ServerConfiguration | Where-Object { $_.Id -eq $Id }
        if ($serverEntry) {
            foreach ($property in ($PSBoundParameters.Keys | Where-Object { $_ -notin $parametersToIgnore} )) {
                Write-Verbose "Changing [$property] of entry #$Id"

                $serverEntry.$property = Get-Variable $property -ValueOnly
            }
        }
        else {
            $writeErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "No entry could be found at index $Id"
                ErrorId       = "AtlassianPS.ServerData.NoEntryExists"
                Category      = "InvalidData"
                TargetObject  = $Id
            }
            WriteError @writeErrorSplat
        }
    }

    end {
        Save-Configuration

        Write-Verbose "Function ended"
    }
}
