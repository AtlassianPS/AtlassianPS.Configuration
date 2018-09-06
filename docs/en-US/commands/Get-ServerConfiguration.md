---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Get-ServerConfiguration/
---
# Get-ServerConfiguration

## SYNOPSIS

Get the data of a stored server.

## SYNTAX

### _All (Default)

```powershell
Get-AtlassianServerConfiguration [<CommonParameters>]
```

### ServerDataByUri

```powershell
Get-AtlassianServerConfiguration [-Uri] <Uri> [<CommonParameters>]
```

### ServerDataByName

```powershell
Get-AtlassianServerConfiguration [-Name] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Retrieve the stored servers.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AtlassianServerConfiguration
```

Get all stored servers

### EXAMPLE 2

```powershell
Get-AtlassianServerConfiguration -Name "prod"
```

Get the data of the server with Name "prod"

### EXAMPLE 3

```powershell
Get-AtlassianServerConfiguration -Uri "https://myserver.com"
```

Get the data of the server with address <https://myserver.com>

## PARAMETERS

### -Uri

Address of the stored server.

Is not case sensitive

```yaml
Type: Uri
Parameter Sets: ServerDataByUri
Aliases: Url, Address

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Name of the server that was defined when stored.

Is not case sensitive

```yaml
Type: String[]
Parameter Sets: ServerDataByName
Aliases: ServerName, Alias

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

## OUTPUTS

### [AtlassianPS.ServerData]

## NOTES

## RELATED LINKS

[AtlassianPS.ServerData](../../classes/AtlassianPS.ServerData/)

[Set-ServerConfiguration](../Set-ServerConfiguration/)

[Remove-ServerConfiguration](../Remove-ServerConfiguration/)

[Export-Configuration](../Export-Configuration/)
