#region Dependencies
# Load the Module's namespace from C#
if (-not("AtlassianPS.ServerData" -as [Type])) {
    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Types.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
   Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}
#endregion Dependencies

#region ModuleConfig
# Add our own Converters for serialization
Configuration\Add-MetadataConverter @{
    [AtlassianPS.ServerData] = { "AtlassianPSServerData -Id {0} -Name '{1}' -Uri '{2}' -Type '{3}' -Headers {4}" -f $_.Id, $_.Name, $_.Uri, $_.Type, (ConvertTo-Metadata $_.Headers) }
    AtlassianPSServerData = {
        param($Id, $Name, $Uri, $Type, $Headers)
        [AtlassianPS.ServerData]$PSBoundParameters
    }
}

# Load configuration using
# https://github.com/PoshCode/Configuration
$script:Configuration = Configuration\Import-Configuration -CompanyName "AtlassianPS" -Name "AtlassianPS.Configuration"
if (-not $script:Configuration.ServerList) {
    $script:Configuration.ServerList = [System.Collections.Generic.List[AtlassianPS.ServerData]]::new()
}
#endregion ModuleConfig

#region LoadFunctions
$PublicFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $file
        )
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
#endregion LoadFunctions
