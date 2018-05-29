function Get-BreadCrumbs {
    param(
        [String]$Delimiter = " > "
    )
    # We can deffinitely skip the first thing, which is THIS function (and the last thing will be <ScriptBlock> if it was typed at the console
    # Get-PSCallStack | Select -Skip 1 -Expand Command | Out-Host
    # Write-Host "====="

    # Here we skip two things (first is this line, second is the call to Write-Scope):
    # Get-PSCallStack | Select -Skip 2 | % { $_.Position.Text } | Out-Host
    # Write-Host "====="

    $depth = 1
    $path = New-Object -TypeName System.Collections.ArrayList
    while ($depth) {
        try {
            # Write-Host ("{0:n2} {1}" -f $depth, (Get-Variable MyInvocation -Scope $depth -ValueOnly).MyCommand.Name)
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
