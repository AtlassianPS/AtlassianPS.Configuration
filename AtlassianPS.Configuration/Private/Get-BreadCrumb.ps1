function Get-BreadCrumb {
    param(
        [String]$Delimiter = " > "
    )

    $path = Get-PSCallStack | Select-Object -Skip 1 |
        ForEach-Object { $_.FunctionName -replace '<(Begin|Process|End)>$', '' } |
        Where-Object { $_ -ne '<ScriptBlock>' }
    $path -join $Delimiter
}
