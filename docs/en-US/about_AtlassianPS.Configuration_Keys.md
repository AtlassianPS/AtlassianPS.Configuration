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

Is a key-value set which describes the user's preference on how to see verbose
and debug messages.

The structure of the for this Hashtable is documented bellow.
But here is a json representation of how it could be used:

```json
"message": {
    "style": {
        // show a line with the Bread Crumbs of the caller stack
        "breadcrumbs": true,

        // how many whitespaces should be used for indenting the
        // message
        "indent": true,

        // show the name of the calling function - this is ignored
        // if breadcrumbs is active
        "functionname": true,

        // show the timestamp (HH:mm:ss format) of the message
        "timestamp": true
    }
}
```

```yaml
DataType: Hashtable
Allowed Values: Style
Used By: none yet
```

### Style

Is a Hashtable used by the "Message" Key (see above).

```yaml
DataType: Hashtable
Allowed Values: breadcrumbs, indent, functionname, timestamp
Used By: see "Message" above
```

#### Breadcrumbs

Shows a line with the Bread Crumbs of the caller stack

```yaml
DataType: Boolean
Allowed Values: true, false
Used By: see "Message" above
```

#### Indent

How many whitespaces should be used for indenting the message

```yaml
DataType: Boolean
Allowed Values: true, false
Used By: see "Message" above
```

#### FunctionName

Shows the name of the calling function - this is ignored if breadcrumbs is active

```yaml
DataType: Boolean
Allowed Values: true, false
Used By: see "Message" above
```

#### Timestamp

Show the timestamp (HH:mm:ss format) of the message

```yaml
DataType: Boolean
Allowed Values: true, false
Used By: see "Message" above
```

# NOTE

In case you find that this document is not be up-to-date,
please let us know on github as an
[issue](https://github.com/AtlassianPS/AtlassianPS.Configuration/issues/new).
