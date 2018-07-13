---
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/
locale: en-US
layout: documentation
permalink: /docs/AtlassianPS.Configuration/
hide: true
---
# AtlassianPS.Configuration

## about_AtlassianPS.Configuration

# SHORT DESCRIPTION

AtlassianPS.Configuration is a module that offers a common set of tools to the <https://AtlassianPS.org> products to handle user-specific configuration.

# LONG DESCRIPTION

This module contains a set cmdlets for AtlassianPS products,
such as JiraPS and ConfluencePS,to use for store
and retrieving user settings.

The module shall be imported into the global scope
and thus making the configuration available across all AtlassianPS products
loaded into the same powershell workspace.
By using the `Export-AtlassianConfiguration` cmdlets, the user is able to share
the settings across workspaces.

The module stores a Hashtable in a private variable - not available in the
global scope.
This Hashtable can be extended with virtually any key-value pair by using the
module's cmdlets.
Such a key-value pair will not produce any change in behavior of any other
cmdlet by itself; the module using this module, AtlassinaPS.Configuration,
must implement a usage for the key-value.
A documentation of the currently implemented key-value pairs can be found in
[About AtlassianPS.Configuration Keys](about/implemented-keys.html).

When the user decided to export the configuration (persist to disk) with the
`Export-AtlassianConfiguration` cmdlet, this module will store it in a
`Configuration.psd1` file.
This file can be deployed to other systems.
When this module is loaded, the exported configuration will be loaded again.

> AtlassianPS.Configuration uses
> [PoshCode/Configuration](Export-AtlassianConfiguration) for importing and
> exporting the configuration.  
> Where the configuration is exported and how the configuration is imported is
> described [here](https://github.com/PoshCode/Configuration#how-it-works)

# EXAMPLES

> This example uses [ConfluencePS](https://atlassianps.org/docs/ConfluencePS) for illustration.  
> This example uses [splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting).

```powershell
Import-Module ConfluencePS   # AtlassianPS.Configuration is imported automatically

$serverData = @{
    # BaseURL of the server
    Uri = "https://powershell.atlassian.net/wiki"
    # Name with which you want to address this server
    ServerName = "AtlassianPS - wiki"
    # Type of the Atlassian product
    Type = "Confluence"
}
Set-AtlassianServerConfiguration @serverData

Get-ConfluenceSpace -Server "AtlassianPS - wiki"
```

# NOTE

This project is run by the volunteer organization AtlassianPS.
We are always interested in hearing from new users!
Find us on GitHub or Slack, and let us know what you think.

# SEE ALSO

[AtlassianPS org](https://atlassianps.org)

[AtlassianPS Slack team](https://atlassianps.org/slack)

# KEYWORDS

- Atlassian
- AtlassianPS
- Atlassian Configuration
- Bitbucket Server
- BitbucketPS Server
- Confluence Server
- ConfluencePS Server
- Hipchat Server
- HipchatPS Server
- Jira Server
- JiraPS Server
