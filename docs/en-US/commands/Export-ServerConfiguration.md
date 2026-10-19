---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Export-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Export-ServerConfiguration/
---
# Export-ServerConfiguration

## SYNOPSIS

Export portable non-secret server profiles.

## SYNTAX

### __AllParameterSets

```powershell
Export-AtlassianServerConfiguration -Path <String> [-Name <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Export portable non-secret server profiles.

## EXAMPLES

### EXAMPLE 1

```powershell
$path = Join-Path ([IO.Path]::GetTempPath()) 'atlassianps-profile-example.json'
Export-AtlassianServerConfiguration -Path $path -WhatIf
```

Preview portable export without creating a file.

## PARAMETERS

### -Path

Literal path of a versioned JSON profile document containing approved non-secret fields only.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Friendly name, compared without case sensitivity within a product.

```yaml
Type: String[]
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

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Export-ServerConfiguration/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
