---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Join-Hashtable/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Join-Hashtable/
---
# Join-Hashtable

## SYNOPSIS

Merges multiple hashtables into a single hashtable.

## SYNTAX

```powershell
Join-AtlassianHashtable [-Hashtable] <IDictionary[]> [<CommonParameters>]
```

## DESCRIPTION

Combines each incoming dictionary into one output hashtable. Later entries win
when keys overlap.

## EXAMPLES

### EXAMPLE 1

```powershell
@(
    @{ Name = 'A'; Value = 1 }
    @{ Value = 2; Enabled = $true }
) | Join-AtlassianHashtable
```

Returns one hashtable where `Value` is `2` and all keys are present.

## PARAMETERS

### -Hashtable

One or more dictionaries to merge.

```yaml
Type: IDictionary[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

System.Collections.IDictionary[]

## OUTPUTS

System.Collections.Hashtable

## NOTES

## RELATED LINKS

[ConvertTo-Hashtable](../ConvertTo-Hashtable/)
