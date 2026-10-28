---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Disconnect-Connection/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Disconnect-Connection/
---
# Disconnect-Connection

## SYNOPSIS

Disconnect locally and invalidate a retained connection handle.

## SYNTAX

### Object

```powershell
Disconnect-AtlassianConnection -Connection <AtlassianPS.Connection> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name

```powershell
Disconnect-AtlassianConnection -Name <string> -Product <string> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Id

```powershell
Disconnect-AtlassianConnection -Id <int> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Disconnect locally and invalidate a retained connection handle.

## EXAMPLES

### EXAMPLE 1

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
$connection | Disconnect-AtlassianConnection
```

Disconnect using the connection object.

### EXAMPLE 2

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
Disconnect-AtlassianConnection -Product Jira -Name example
```

Disconnect by product and name.

### EXAMPLE 3

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
Disconnect-AtlassianConnection -Id $connection.Id
```

Disconnect by ID.

## PARAMETERS

### -Connection

Live connection object from this shared runtime.
Removed and deserialized handles are rejected.

```yaml
Type: Connection
Parameter Sets: Object
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Friendly name, compared without case sensitivity within a product.

```yaml
Type: String
Parameter Sets: Name
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product

Product that owns this connection, such as Jira.

```yaml
Type: String
Parameter Sets: Name
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Runtime numeric identifier, unique across products until the shared module unloads.

```yaml
Type: Int32
Parameter Sets: Id
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

Supports the standard PowerShell common parameters.

## INPUTS

### AtlassianPS.Connection

## OUTPUTS

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Disconnect-Connection/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
