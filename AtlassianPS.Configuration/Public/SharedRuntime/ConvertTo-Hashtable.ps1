function ConvertTo-Hashtable {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]
        $InputObject
    )

    process {
        $hash = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = $property.Value
        }

        $hash
    }
}
