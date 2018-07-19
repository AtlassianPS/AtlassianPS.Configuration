---
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/about/implemented-keys.html
locale: en-US
layout: documentation
permalink: /docs/AtlassianPS.Configuration/about/implemented-keys.html
---
# AtlassianPS.Configuration Implemented Keys

## about_AtlassianPS.Configuration_Keys

# SHORT DESCRIPTION

This article documents the Keys that AtlassianPS.Configuration supports and
how they are used.

# LONG DESCRIPTION

Here is the list of the currently supported Keys:

## ServerList

Is a list of servers currently stored by the user.

> ServerData objects are describe here:  
> <https://atlassianps.org/docs/AtlassianPS.Configuration/classes/AtlassianPS.ServerData/>

```yaml
DataType: AtlassianPS.ServerData
Allowed Values: any
Used By: none yet
```

## Message

Is a [AtlassianPS.MessageStyle](../classes/AtlassianPS.MessageStyle/) which
describes the user's preference on how to see verbose and debug messages.

```yaml
DataType: AtlassianPS.MessageStyle
Allowed Values: any
Used By: none yet
```

# NOTE

In case you find that this document is not be up-to-date,
please let us know on github as an
[issue](https://github.com/AtlassianPS/AtlassianPS.Configuration/issues/new).

# RELATED LINKS

[AtlassianPS.MessageStyle](../classes/AtlassianPS.MessageStyle/)
