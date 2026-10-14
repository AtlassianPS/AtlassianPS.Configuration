---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Select-Connection/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Select-Connection/
---
# Select-Connection

## SYNOPSIS

Select an existing connection as its product's default.

## SYNTAX

### Object

```powershell
Select-AtlassianConnection -Connection <Connection> [<CommonParameters>]
```

### Name

```powershell
Select-AtlassianConnection -Name <String> -Product <String> [<CommonParameters>]
```

### Id

```powershell
Select-AtlassianConnection -Id <Int32> [<CommonParameters>]
```

## DESCRIPTION

Select an existing connection as its product's default.

## EXAMPLES

### EXAMPLE 1

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
$connection | Select-AtlassianConnection
$connection | Disconnect-AtlassianConnection
```

Select using a pipeline object.

### EXAMPLE 2

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
Select-AtlassianConnection -Product Jira -Name example
$connection | Disconnect-AtlassianConnection
```

Select by product-scoped name.

### EXAMPLE 3

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
Select-AtlassianConnection -Id $connection.Id
$connection | Disconnect-AtlassianConnection
```

Select by registry-wide ID.

## PARAMETERS

### -Connection

Live connection object from this shared runtime. Removed and deserialized handles are rejected.

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

### AtlassianPS.Connection

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Select-Connection/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
