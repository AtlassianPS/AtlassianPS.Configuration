---
layout: documentation
Module Name: AtlassianPS.Configuration
permalink: /docs/AtlassianPS.Configuration/classes/AtlassianPS.ServerData/
---
# AtlassianPS.ServerData

## SYNOPSIS

Object that describes the a server for AtlassianPS modules to connect to.

## DESCRIPTION

AtlassianPS modules per definition connect to a web server.
This class describes describes one server.

## CONSTRUCTORS

### Name, Uri, Type

A new object of type `[AtlassianPS.ServerData]` can be create by providing a
string for `Name`, `Uri` and `Type`

```powershell
New-Object -TypeName AtlassianPS.ServerData -ArgumentList "<Name>", "<Uri>", "<Type>"
```

### Hashtable

A new object of type `[AtlassianPS.ServerData]` can be create by providing a
hashtable containing keys for `Name`, `Uri` and `Type`

```powershell
[AtlassianPS.ServerData]@{ Id = <Id> Name = "<Name>"; Uri = "<Uri>"; Type = "<Type>" }
```

## PROPERTIES

### Name

Name is used to identify the server. Functions should be able to find the correct server based on this property.

```yaml
Type: String
Required: True
Default value: None
```

### Uri

Uri is the web address that will be used for this server entry.

```yaml
Type: Uri
Required: True
Default value: None
```

### Type

Type is a [AtlassianPS.ServerType](../../enumerations/AtlassianPS.ServerType/) that defines what is the type of this server entry

```yaml
Type: AtlassianPS.ServerType
Required: True
Default value: None
```

### Session

Session is a `[WebRequestSession]` object which contains the information for connecting to this server

```yaml
Type: WebRequestSession
Required: False
Default value: None
```

### Headers

Headers is a `[Hashtable]` describing the Headers that should be used for this server

```yaml
Type: Hashtable
Required: False
Default value: None
```

## METHODS

### ToString()

The method for casting an object of this class to string is overwritten.

When cast to string, this will return `[$Id] $Title`.
