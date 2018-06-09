function Get-BreadCrumb {
    param(
        [String]$Delimiter = " > "
    )

    $depth = 1
    $path = New-Object -TypeName System.Collections.ArrayList

    while ($depth) {
        try {
            $null = $path.Add((Get-Variable MyInvocation -Scope $depth -ValueOnly).MyCommand.Name)
            $depth++
        }
        catch {
            $depth = 0
        }
    }

    $path.Remove("")
    $path -join $Delimiter
}
