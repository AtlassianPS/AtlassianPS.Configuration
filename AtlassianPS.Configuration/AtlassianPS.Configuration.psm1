#region Dependencies
Import-Module Metadata -MinimumVersion 1.5.7 -MaximumVersion '1.*' -Global -ErrorAction Stop

$incompatibleConfiguration = @(Get-Module Configuration -All | Where-Object { $_.Version -lt [Version]'1.6.0' -or $_.Version.Major -ne 1 })
if ($incompatibleConfiguration.Count) {
    throw 'An incompatible Configuration dependency is loaded. Start a fresh process with Configuration >=1.6.0 within major 1.'
}

if (('AtlassianPS.ServerData' -as [Type]) -and -not ('AtlassianPS.Connection' -as [Type])) {
    throw 'An older Configuration type assembly is loaded. Start a fresh PowerShell session before importing this version.'
}

# Load the Module's namespace from C#
if (-not("AtlassianPS.ServerData" -as [Type])) {
    $assemblyReferences = @(
        'Microsoft.CSharp'
        'Microsoft.PowerShell.Commands.Utility'
        'System.Management.Automation'
        'System.Runtime.Extensions'
        'System.Security.Cryptography.X509Certificates'
    )

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $assemblyReferences += 'System.Security.Cryptography'
    }

    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Types.cs) -ReferencedAssemblies $assemblyReferences
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation, System.Runtime.Extensions, System.Security.Cryptography.X509Certificates
}

#endregion Dependencies

if ($env:ATLASSIANPS_CONFIGURATION_ROOT) {
    $configurationRoot = $env:ATLASSIANPS_CONFIGURATION_ROOT
    if (-not [IO.Path]::IsPathRooted($configurationRoot)) { throw 'Configuration root must be an absolute disposable path.' }
    $null = New-Item -Path $configurationRoot -ItemType Directory -Force
    if ((Get-Module Configuration).PrivateData.AtlassianPSTestRoot -ne $configurationRoot) {
        Import-Module Configuration -MinimumVersion 1.6.0 -MaximumVersion '1.*' -Global -Force -ArgumentList @{}, $configurationRoot, $configurationRoot, $configurationRoot -ErrorAction Stop
        (Get-Module Configuration).PrivateData.AtlassianPSTestRoot = $configurationRoot
    }
}

#region ModuleConfig
$script:RegistryGeneration = [Guid]::NewGuid()
$script:NextConnectionId = 0
$script:NextGeneratedName = 0
$script:Connections = @{}
$script:DefaultConnections = @{}
$script:RequestContexts = [Collections.Generic.List[WeakReference]]::new()
$ExecutionContext.SessionState.Module.OnRemove = {
    foreach ($connection in @($script:Connections.Values)) { $connection.Dispose() }
    foreach ($reference in $script:RequestContexts) {
        $context = $reference.Target
        if ($context) { $context.Dispose() }
    }
    $script:RequestContexts.Clear()
    $script:Connections.Clear()
    $script:DefaultConnections.Clear()
}

# Add our own Converters for serialization
Add-MetadataConverter @{
    [AtlassianPS.MessageStyle] = { "AtlassianPSMessageStyle -Indent {0} -TimeStamp {1} -BreadCrumbs {2} -FunctionName {3}" -f (ConvertTo-Metadata $_.Indent), (ConvertTo-Metadata $_.TimeStamp), (ConvertTo-Metadata $_.BreadCrumbs), (ConvertTo-Metadata $_.FunctionName) }
    AtlassianPSMessageStyle    = {
        param($Indent, $TimeStamp, $BreadCrumbs, $FunctionName)
        [AtlassianPS.MessageStyle]$PSBoundParameters
    }
    [AtlassianPS.ServerData]   = { "AtlassianPSServerData -Id {0} -Name {1} -Uri {2} -Type {3} -Headers {4}" -f $_.Id, (ConvertTo-Metadata $_.Name), (ConvertTo-Metadata $_.Uri.AbsoluteUri), (ConvertTo-Metadata $_.Type.ToString()), (ConvertTo-Metadata $_.Headers) }
    AtlassianPSServerData      = {
        param($Id, $Name, $Uri, $Type, $Headers)
        if ([string]::IsNullOrEmpty($Headers)) { $Headers = $null }
        [AtlassianPS.ServerData]@{ Id = $Id; Name = $Name; Uri = $Uri; Type = $Type; Headers = $Headers }
    }
}

#region LoadFunctions
$PublicFunctions = @(
    Get-ChildItem -Path "$PSScriptRoot/Public" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
        Sort-Object -Property FullName
)
$PrivateFunctions = @(
    Get-ChildItem -Path "$PSScriptRoot/Private" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
        Sort-Object -Property FullName
)

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

# Load configuration using
# https://github.com/PoshCode/Configuration
[Hashtable]$script:Configuration = Import-Configuration -CompanyName "AtlassianPS" -Name "AtlassianPS.Configuration"
if (-not $script:Configuration) { $script:Configuration = @{} }
if (-not $script:Configuration.ContainsKey("ServerList")) {
    $script:Configuration.Add("ServerList", [System.Collections.Generic.List[AtlassianPS.ServerData]]::new())
}
#endregion ModuleConfig
