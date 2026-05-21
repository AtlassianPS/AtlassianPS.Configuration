---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertTo-QueryString/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertTo-QueryString/
---
# ConvertTo-QueryString

## SYNOPSIS

Converts a hashtable to a URL query-string fragment.

## SYNTAX

```powershell
ConvertTo-AtlassianQueryString [-InputObject] <Hashtable> [<CommonParameters>]
```

## DESCRIPTION

Builds a query-string value prefixed with `?` from keys and values in a
hashtable. Keys and values are URL-encoded before joining.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-AtlassianQueryString -InputObject @{
    jql = 'project=TEST'
    max = 25
}
```

Returns a query string such as `?jql=project%3dTEST&max=25`.

## PARAMETERS

### -InputObject

Hashtable of key/value pairs to convert into query-string parameters.

```yaml
Type: Hashtable
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

System.Collections.Hashtable

## OUTPUTS

System.String

## NOTES

## RELATED LINKS

[ConvertFrom-QueryString](../ConvertFrom-QueryString/)
