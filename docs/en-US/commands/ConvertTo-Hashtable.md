---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertTo-Hashtable/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertTo-Hashtable/
---
# ConvertTo-Hashtable

## SYNOPSIS

Converts an object into a hashtable by copying its public properties.

## SYNTAX

```powershell
ConvertTo-AtlassianHashtable [-InputObject] <PSObject> [<CommonParameters>]
```

## DESCRIPTION

Enumerates properties on the provided object and returns a hashtable where each
property name becomes a key.

## EXAMPLES

### EXAMPLE 1

```powershell
$obj = [PSCustomObject]@{
    Key = 'Value'
    Count = 2
}
ConvertTo-AtlassianHashtable -InputObject $obj
```

Returns a hashtable with `Key` and `Count` entries.

## PARAMETERS

### -InputObject

Object whose properties are copied into a hashtable.

```yaml
Type: PSObject
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

System.Management.Automation.PSObject

## OUTPUTS

System.Collections.Hashtable

## NOTES

## RELATED LINKS

[Join-Hashtable](../Join-Hashtable/)
