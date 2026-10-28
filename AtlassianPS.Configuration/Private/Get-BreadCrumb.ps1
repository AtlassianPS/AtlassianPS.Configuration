function Get-BreadCrumb {
    <#
    .SYNOPSIS
        Returns caller names as a diagnostic breadcrumb.

    .DESCRIPTION
        Joins call-stack frame names from the nearest caller outward.
        Omits this helper and unnamed script blocks, and removes Begin, Process and End suffixes.

    .PARAMETER Delimiter
        Text inserted between caller names.
        Defaults to a space, greater-than sign and space.

    .EXAMPLE
        Get-BreadCrumb -Delimiter ' > '

        Returns the current caller chain for message formatting.

    .OUTPUTS
        System.String
    #>
    param(
        [String]$Delimiter = " > "
    )

    $path = Get-PSCallStack | Select-Object -Skip 1 |
        ForEach-Object { $_.FunctionName -replace '<(Begin|Process|End)>$', '' } |
        Where-Object { $_ -ne '<ScriptBlock>' }
    $path -join $Delimiter
}
