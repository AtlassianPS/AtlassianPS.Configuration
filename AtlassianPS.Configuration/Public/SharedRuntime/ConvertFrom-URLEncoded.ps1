function ConvertFrom-URLEncoded {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String[]]
        $InputString
    )

    process {
        foreach ($string in $InputString) {
            [System.Web.HttpUtility]::UrlDecode($string)
        }
    }
}
