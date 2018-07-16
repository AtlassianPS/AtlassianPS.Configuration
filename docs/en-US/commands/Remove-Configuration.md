---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Remove-Configuration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Remove-Configuration/
---
# Remove-Configuration

## SYNOPSIS

Remove a configuration entry.

## SYNTAX

```powershell
Remove-AtlassianConfiguration [-Name] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Remove a configuration entry.

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-AtlassianConfiguration -Name "Headers"
```

This command will remove "Headers" configuration.

## PARAMETERS

### -Name

Name under which the value is stored

Is not case sensitive

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

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

[Get-Configuration](../Get-Configuration/)

[Set-Configuration](../Set-Configuration/)
