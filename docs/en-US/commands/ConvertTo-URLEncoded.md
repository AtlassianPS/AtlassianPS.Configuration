---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertTo-URLEncoded/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertTo-URLEncoded/
---
# ConvertTo-URLEncoded

## SYNOPSIS

Encodes text for use in query strings and form payloads.

## SYNTAX

```powershell
ConvertTo-AtlassianURLEncoded [-InputString] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Converts plain text into URL-encoded format by escaping reserved characters.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-AtlassianURLEncoded -InputString 'hello world+value'
```

Returns an encoded value such as `hello+world%2bvalue`.

## PARAMETERS

### -InputString

The plain text values to encode.

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

[ConvertFrom-URLEncoded](../ConvertFrom-URLEncoded/)
