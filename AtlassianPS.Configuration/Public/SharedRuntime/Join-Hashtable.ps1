function Join-Hashtable {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [System.Collections.IDictionary[]]
        $Hashtable
    )

    begin {
        $table = @{}
    }

    process {
        foreach ($item in $Hashtable) {
            if (-not $item) {
                continue
            }

            foreach ($key in $item.Keys) {
                $table[$key] = $item[$key]
            }
        }
    }

    end {
        $table
    }
}
