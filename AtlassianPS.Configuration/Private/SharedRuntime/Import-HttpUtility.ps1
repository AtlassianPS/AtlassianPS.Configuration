function Import-HttpUtility {
    [CmdletBinding()]
    param()

    if ('System.Web.HttpUtility' -as [Type]) {
        return
    }

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        Add-Type -AssemblyName System.Web -ErrorAction Stop
    }
    else {
        Add-Type -AssemblyName System.Web.HttpUtility -ErrorAction Stop
    }
}
