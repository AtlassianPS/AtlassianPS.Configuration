function Join-Hashtable {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [System.Collections.IDictionary[]]
        $Hashtable,

        [Parameter()]
        [ValidateSet('Overwrite', 'Error')]
        [String]
        $OnDuplicate = 'Overwrite'
    )

    begin {
        [Hashtable]$table = @{}
        $isInitialized = $false
    }

    process {
        foreach ($item in $Hashtable) {
            if ($null -eq $item) {
                continue
            }

            if (-not $isInitialized) {
                # Start from the first dictionary so key comparison behavior
                # (for example case sensitivity) is preserved.
                $table = [System.Collections.Hashtable]::new($item)
                $isInitialized = $true
                continue
            }

            foreach ($entry in $item.GetEnumerator()) {
                if ($OnDuplicate -eq 'Error' -and $table.Contains($entry.Key)) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]::new("Duplicate key '$($entry.Key)' was encountered while joining hashtables.")),
                        'JoinHashtable.DuplicateKey',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $entry.Key
                    )
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }

                $table[$entry.Key] = $entry.Value
            }
        }
    }

    end {
        $table
    }
}
