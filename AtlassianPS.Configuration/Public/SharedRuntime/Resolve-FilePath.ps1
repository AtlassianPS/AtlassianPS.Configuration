function Resolve-FilePath {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath', 'LiteralPath')]
        [String]
        $Path
    )

    process {
        $folder = Split-Path -Path $Path -Parent
        $file = Split-Path -Path $Path -Leaf

        if (-not [String]::IsNullOrEmpty($folder)) {
            $folderResolved = Resolve-Path -Path $folder
        }
        else {
            $folderResolved = Resolve-Path -Path $ExecutionContext.SessionState.Path.CurrentFileSystemLocation
        }

        Join-Path -Path $folderResolved.ProviderPath -ChildPath $file
    }
}
