---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertTo-ParameterHash/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertTo-ParameterHash/
---
# ConvertTo-ParameterHash

## SYNOPSIS

Parses a URL query string into a hashtable.

## SYNTAX

```powershell
ConvertTo-AtlassianParameterHash -Uri <Uri> [<CommonParameters>]
```

```powershell
ConvertTo-AtlassianParameterHash [-Query] <String> [<CommonParameters>]
```

## DESCRIPTION

Accepts either a URI or a raw query string and converts the contained
parameters into a decoded hashtable.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-AtlassianParameterHash -Query '?jql=project%3DTEST&max=25'
```

Parses query-string text into key/value entries.

### EXAMPLE 2

```powershell
ConvertTo-AtlassianParameterHash -Uri 'https://example.test/search?jql=project%3DTEST&max=25'
```

Parses the query component of a URI into key/value entries.

## PARAMETERS

### -Uri

URI containing the query string to parse.

```yaml
Type: Uri
Parameter Sets: ByUri
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Query

Raw query string to parse.

```yaml
Type: String
Parameter Sets: ByString
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

System.Uri, System.String

## OUTPUTS

System.Collections.Hashtable

## NOTES

## RELATED LINKS

[ConvertTo-GetParameter](../ConvertTo-GetParameter/)
