---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Set-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Set-ServerConfiguration/
---
# Set-ServerConfiguration

## SYNOPSIS

Stores Server object for the module to known with what server it should talk to.

## SYNTAX

```powershell
Set-ServerConfiguration [-Uri] <Uri> [[-ServerName] <String>] [-Type] <ServerType>
 [[-Session] <WebRequestSession>] [[-Headers] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

This function allows for several Server object to be stored in memory.
Stored servers are used by the commands in order to know with what server to communicate.

The stored servers can be exported to file with `Export-Configuration`.
_Exported servers will be imported automatically when the module is loaded._

## EXAMPLES

### EXAMPLE 1

```powershell
Set-AtlassianServerConfiguration -Uri "https://server.com/" -ServerName "Server Prod" -Type "Jira"
```

This command will store the Jira server address and name in memory and allow other
commands to identify the server by the name "Server Prod"

## PARAMETERS

### -Uri

Address of the Server.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: Url, Address

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ServerName

Name with which this server will be stored.

If no name is provided, the "Authority" of the address will be used.
This value must be unique.

In case the ServerName was already saved, it will be overwritten.

Example for "Authority":
  https://**www.google.com**/maps?hl=en --> "www.google.com"

Is not case sensitive

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name, Alias

Required: False
Position: 2
Default value: $Uri.Authority
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type

Type of the server to store.

This can be:

* Bitbucket
* Confluence
* Jira

```yaml
Type: ServerType
Parameter Sets: (All)
Aliases:
Accepted values: BITBUCKET, CONFLUENCE, JIRA

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Session

Stores a WebSession to the server object.

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Headers

Stores the Headers that should be used for this server

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[AtlassianPS.ServerData](../../classes/AtlassianPS.ServerData/)

[Get-ServerConfiguration](../Get-ServerConfiguration/)

[Remove-ServerConfiguration](../Remove-ServerConfiguration/)

[Export-Configuration](../Export-Configuration/)
