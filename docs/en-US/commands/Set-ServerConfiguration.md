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

Updates a stores Server entry.

## SYNTAX

```powershell
Set-AtlassianServerConfiguration [-Id] <UInt32> [[-Uri] <Uri>]
 [[-Name] <String>] [-Type] <ServerType> [[-Session] <WebRequestSession>]
 [[-Headers] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

This function provides the means to change a stored server entry.

## EXAMPLES

### EXAMPLE 1

```powershell
Add-AtlassianServerConfiguration -Uri "https://server.com/" -Type "Confluence"
Set-AtlassianServerConfiguration -Id 1 -Uri "https://atlassian.net"
```

This command will replace the Uri stored of the first entry of the stored servers.

### EXAMPLE 2

```powershell
Add-AtlassianServerConfiguration -Name "My Server" -Uri "https://server.com/" -Type "Jira"
Set-AtlassianServerConfiguration -Id 1 -Name "wiki" -Type "Confluence"
```

This command will replace the Name and Type of the first entry of the stored servers.

### EXAMPLE 3

```powershell
Add-AtlassianServerConfiguration -Name "JiraServer" -Uri "https://server.com/" -Type "Jira"
Get-AtlassianServerConfiguration |
    Where Type -eq "JIRA" |
    Set-AtlassianServerConfiguration -Uri "https://atlassian.net"
```

This command will replace the Uri of all stored Jira servers with the new address.

## PARAMETERS

### -Id

Identifier (index) of the entry to update

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Uri

Absolute server endpoint without user information, a query string or a fragment.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: Url, Address

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Name with which this server will be stored.

When omitted, the existing server name is kept.
This value must be unique.

In case the ServerName was already saved for another entry, an error is written and the existing entries are not changed.

Example for "Authority":
  https://**www.google.com**/maps --> "www.google.com"

Is not case sensitive

```yaml
Type: String
Parameter Sets: (All)
Aliases: ServerName, Alias

Required: False
Position: 3
Default value: None
Accept pipeline input: False
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

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session

Compatibility WebRequestSession retained on the in-memory server object.
It is excluded from saved and portable profiles and is ignored by Connect.
Supply authentication when creating a connection.

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers

Compatibility headers retained on the in-memory server object.
Headers are omitted when saving profiles, and portable exports reject profiles with nonempty headers.
Connect uses the profile endpoint and requires explicit authentication.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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

## OUTPUTS

## NOTES

## RELATED LINKS

[AtlassianPS.ServerData](../../classes/AtlassianPS.ServerData/)

[Get-ServerConfiguration](../Get-ServerConfiguration/)

[Remove-ServerConfiguration](../Remove-ServerConfiguration/)

[Export-Configuration](https://github.com/PoshCode/Configuration)
