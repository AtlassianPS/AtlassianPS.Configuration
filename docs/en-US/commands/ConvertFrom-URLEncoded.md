---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertFrom-URLEncoded/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertFrom-URLEncoded/
---
# ConvertFrom-URLEncoded

## SYNOPSIS

Decodes URL-encoded strings.

## SYNTAX

```powershell
ConvertFrom-AtlassianURLEncoded [-InputString] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Converts URL-encoded values into plain text by decoding percent-encoded and
`+`-separated values.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertFrom-AtlassianURLEncoded -InputString 'hello+world%2Bvalue'
```

Returns `hello world+value`.

## PARAMETERS

### -InputString

The URL-encoded string values to decode.

```yaml
Type: String[]
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

System.String[]

## OUTPUTS

System.String

## NOTES

## RELATED LINKS

[ConvertTo-URLEncoded](../ConvertTo-URLEncoded/)
