---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-Configuration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Get-Configuration/
---
# Get-Configuration

## SYNOPSIS

Retrieve a stored configuration

## SYNTAX

```powershell
Get-AtlassianConfiguration [[-Name] <String[]>] [-ValueOnly] [<CommonParameters>]
```

## DESCRIPTION

Retrieve a stored configuration

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AtlassianConfiguration
```

Get all stored servers

### EXAMPLE 2

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{ Authorization = "Basic ABCDEF" }
Get-AtlassianConfiguration -Name "Headers"
```

Get configuration data in key "Headers"

## PARAMETERS

### -Name

Name of the configuration to be retrieved

Is not case sensitive

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -ValueOnly

Indicates that this cmdlet gets only the value of the variable.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [System.Management.Automation.PSObject]

## NOTES

## RELATED LINKS

[Set-Configuration](../Set-Configuration/)

[Remove-Configuration](../Remove-Configuration/)

[Export-Configuration](../Export-Configuration/)
