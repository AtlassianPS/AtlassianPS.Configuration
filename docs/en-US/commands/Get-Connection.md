---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-Connection/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Get-Connection/
---
# Get-Connection

## SYNOPSIS

List live connections without HTTP or configuration IO.

## SYNTAX

### __AllParameterSets

```powershell
Get-AtlassianConnection [-Product <String>] [-Name <String>] [-Id <Int32>] [-Default] [<CommonParameters>]
```

## DESCRIPTION

List live connections without HTTP or configuration IO.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AtlassianConnection
```

List every active product connection.

## PARAMETERS

### -Product

Product that owns this connection, such as Jira.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Friendly name, compared without case sensitivity within a product.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Runtime numeric identifier, unique across products until the shared module unloads.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default

Use or replace the current product default. The first successful registration selects itself automatically.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

Supports the standard PowerShell common parameters.

## INPUTS

## OUTPUTS

### AtlassianPS.Connection

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-Connection/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
