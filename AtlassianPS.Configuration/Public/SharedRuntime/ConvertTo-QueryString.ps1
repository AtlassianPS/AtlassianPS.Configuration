function ConvertTo-QueryString {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Hashtable]
        $InputObject
    )

    process {
        if ($InputObject.Count -eq 0) {
            return ''
        }

        $pairs = foreach ($key in $InputObject.Keys) {
            $encodedKey = ConvertTo-URLEncoded -InputString "$key"
            $value = $InputObject[$key]

            if ($null -eq $value -or "$value" -eq '') {
                "$encodedKey="
            }
            else {
                "{0}={1}" -f $encodedKey, (ConvertTo-URLEncoded -InputString "$value")
            }
        }

        '?' + ($pairs -join '&')
    }
}
