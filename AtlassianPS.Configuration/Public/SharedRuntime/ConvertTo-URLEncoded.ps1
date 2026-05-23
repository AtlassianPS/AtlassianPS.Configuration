function ConvertTo-URLEncoded {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String[]]
        $InputString
    )

    begin {
        if (-not ('System.Web.HttpUtility' -as [Type])) {
            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                Add-Type -AssemblyName System.Web -ErrorAction Stop
            }
            else {
                Add-Type -AssemblyName System.Web.HttpUtility -ErrorAction Stop
            }
        }
    }

    process {
        foreach ($string in $InputString) {
            [System.Web.HttpUtility]::UrlEncode($string)
        }
    }
}
