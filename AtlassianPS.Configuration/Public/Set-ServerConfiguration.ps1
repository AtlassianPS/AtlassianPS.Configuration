function Set-ServerConfiguration {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
    [OutputType( [void] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [UInt32]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Url', 'Address')]
        [ValidateScript( { $_.IsAbsoluteUri -and -not ($_.UserInfo -or $_.Query -or $_.Fragment) } )]
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
        $configurationChanged = $false
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage -BoundParameters $PSBoundParameters
        if ($PSBoundParameters.ContainsKey('Session')) {
            Write-Warning 'Profile Session is deprecated and is never used by Connect. Supply authentication to Connect instead.'
        }
        if ($Headers.Count) {
            Write-Warning 'Profile headers are retained only in memory and are ignored by Connect. Supply authentication when connecting.'
        }

        $serverEntry = Get-ServerConfiguration | Where-Object { $_.Id -eq $Id }
        if ($serverEntry) {
            if ($PSBoundParameters.ContainsKey('Name') -and (Get-ServerConfiguration | Where-Object { $_.Id -ne $Id -and $_.Name -eq $Name })) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "An entry with name [$Name] already exists"
                    ErrorId       = "AtlassianPS.ServerData.EntryExists"
                    Category      = "InvalidData"
                    TargetObject  = $Name
                }
                WriteError @writeErrorSplat
                return
            }

            if ($PSCmdlet.ShouldProcess("#$Id ($($serverEntry.Name))", "Update server configuration")) {
                foreach ($property in ($PSBoundParameters.Keys | Where-Object { $_ -notin $parametersToIgnore } )) {
                    Write-Verbose "Changing [$property] of entry #$Id"

                    $serverEntry.$property = Get-Variable $property -ValueOnly
                    $configurationChanged = $true
                }
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
        if ($configurationChanged) {
            Save-Configuration
        }

        Write-Verbose "Function ended"
    }
}
