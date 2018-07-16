---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Remove-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Remove-ServerConfiguration/
---
# Remove-ServerConfiguration

## SYNOPSIS

Remove a Stores Server from memory.

## SYNTAX

```powershell
Remove-AtlassianServerConfiguration [-Name] <String[]> [<CommonParameters>]
```

## DESCRIPTION

This function allows for several Server object to be removed in memory.

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-AtlassianServerConfiguration -Name "Server Prod"
```

This command will remove the server identified as "Server Prod" from memory.

## PARAMETERS

### -Name

Name with which this server is stored.

Is case sensitive

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ServerName, Alias

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-ServerConfiguration](../Get-ServerConfiguration/)

[Set-ServerConfiguration](../Set-ServerConfiguration/)
