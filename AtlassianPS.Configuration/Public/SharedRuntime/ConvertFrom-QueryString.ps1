function ConvertFrom-QueryString {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding(DefaultParameterSetName = 'ByString')]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByUri')]
        [Uri]
        $Uri,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'ByString')]
        [String]
        $Query
    )

    process {
        $getParameter = @{}

        if ($Uri) {
            $Query = $Uri.Query
        }

        if ($Query -match '^\?.+') {
            $Query.TrimStart('?').Split('&') | ForEach-Object {
                $key, $value = $_.Split('=', 2)
                if (-not [String]::IsNullOrEmpty($key)) {
                    $decodedKey = ConvertFrom-URLEncoded -InputString $key
                    $decodedValue = if ([String]::IsNullOrEmpty($value)) { $value } else { ConvertFrom-URLEncoded -InputString $value }
                    $getParameter[$decodedKey] = $decodedValue
                }
            }
        }

        $getParameter
    }
}
