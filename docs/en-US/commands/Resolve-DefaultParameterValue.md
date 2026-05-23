---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-DefaultParameterValue/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Resolve-DefaultParameterValue/
---
# Resolve-DefaultParameterValue

## SYNOPSIS

Builds default-parameter entries for matching commands and parameters.

## SYNTAX

```powershell
Resolve-AtlassianDefaultParameterValue [-Reference] <Hashtable> [-CommandName] <String[]>
 [[-Target] <Hashtable>] [[-ParameterName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Selects matching entries from a reference hashtable and writes them into a
target hashtable using `Command:Parameter` keys.

## EXAMPLES

### EXAMPLE 1

```powershell
$reference = @{
    'Invoke-WebRequest:TimeoutSec' = 30
    '*:Verbose' = $true
}

Resolve-AtlassianDefaultParameterValue `
    -Reference $reference `
    -CommandName 'Invoke-WebRequest' `
    -ParameterName 'TimeoutSec', 'Verbose'
```

Returns a hashtable with resolved defaults for the requested command.

## PARAMETERS

### -Reference

Hashtable containing default values in `Command:Parameter` format.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandName

One or more command names used to match reference entries.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Target

Hashtable to receive resolved values. A new hashtable is used by default.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterName

Parameter names to match. Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

None

## OUTPUTS

System.Collections.Hashtable

## NOTES

## RELATED LINKS

[Join-Hashtable](../Join-Hashtable/)
