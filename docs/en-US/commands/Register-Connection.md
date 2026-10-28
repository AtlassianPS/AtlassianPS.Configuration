---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Register-Connection/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Register-Connection/
---
# Register-Connection

## SYNOPSIS

Register a product-validated candidate in the shared runtime.

## SYNTAX

### __AllParameterSets

```powershell
Register-AtlassianConnection [-Connection] <AtlassianPS.Connection> [-Default] [<CommonParameters>]
```

## DESCRIPTION

Register a product-validated candidate in the shared runtime.

This is a module integration API.
Use the product Connect command for ordinary sign-in.

## EXAMPLES

### EXAMPLE 1

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.SetValidationResult('Server', $null)
$connection = Register-AtlassianConnection -Connection $candidate
$connection | Disconnect-AtlassianConnection
```

Register after product validation and disconnect when finished.
SetValidationResult records validation; it does not perform HTTP itself.

## PARAMETERS

### -Connection

Live connection object from this shared runtime.
Removed and deserialized handles are rejected.

```yaml
Type: Connection
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default

Use or replace the current product default.
The first successful registration selects itself automatically.

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

### AtlassianPS.Connection

## OUTPUTS

### AtlassianPS.Connection

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Register-Connection/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
