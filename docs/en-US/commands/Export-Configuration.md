---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Export-Configuration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Export-Configuration/
---
# Export-Configuration

## SYNOPSIS

Store the server configuration to disk

## SYNTAX

```powershell
Export-Configuration [<CommonParameters>]
```

## DESCRIPTION

This allows to store the Servers stored in the module's memory to disk.
By doing this, the module will load the servers back into memory every time it is loaded.

_Sessions are not stored when exported._

## EXAMPLES

### EXAMPLE 1

```powershell
Set-ServerConfiguration -Uri "https://server.com"
Export-Configuration
```

Stores the server to disk.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

## OUTPUTS

## NOTES

This functionality uses [PoshCode/Configuration](https://github.com/PoshCode/Configuration).

## RELATED LINKS

[Set-Configuration](../Set-Configuration/)
