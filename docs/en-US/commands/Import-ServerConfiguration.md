---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Import-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Import-ServerConfiguration/
---
# Import-ServerConfiguration

## SYNOPSIS

Validate and import portable non-secret server profiles.

## SYNTAX

### __AllParameterSets

```powershell
Import-AtlassianServerConfiguration -Path <String> [-Replace] [<CommonParameters>]
```

## DESCRIPTION

Validate and import portable non-secret server profiles.

## EXAMPLES

### EXAMPLE 1

```powershell
$path = Join-Path ([IO.Path]::GetTempPath()) 'atlassianps-profile-example.json'
Set-Content -LiteralPath $path -Value '{"SchemaVersion":1,"ServerList":[]}'
Import-AtlassianServerConfiguration -Path $path -WhatIf
Remove-Item -LiteralPath $path
```

Validate a data-only document and preview its import.

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

### -Replace

Replace matching profile names after the complete import has passed validation.

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

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Import-ServerConfiguration/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
