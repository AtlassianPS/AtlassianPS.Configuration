---
layout: module
permalink: /module/AtlassianPS.Configuration/
---
# [AtlassianPS.Configuration](https://atlassianps.org/module/AtlassianPS.Configuration)

[![GitHub release](https://img.shields.io/github/release/AtlassianPS/AtlassianPS.Configuration.svg)](https://github.com/AtlassianPS/AtlassianPS.Configuration/releases/latest) [![Build status](https://img.shields.io/appveyor/ci/AtlassianPS/AtlassianPS.Configuration/master.svg)](https://ci.appveyor.com/project/AtlassianPS/AtlassianPS.Configuration/branch/master) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/AtlassianPS.Configuration.svg)](https://www.powershellgallery.com/packages/AtlassianPS.Configuration) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

AtlassianPS.Configuration is a module that offers a common set of tools to the [AtlassianPS] products to handle user-specific configuration.

Join the conversation on [![SlackLogo][] AtlassianPS.Slack.com](https://atlassianps.org/slack)

[SlackLogo]: https://atlassianps.org/assets/img/Slack_Mark_Web_28x28.png
<!--more-->

---

## Instructions

### Installation

> This module does not need to be installed manually.  
> [AtlassianPS] products which use this module will install it automatically using the [PowerShell Gallery].

Install AtlassianPS.Configuration from the [PowerShell Gallery]! `Install-Module` requires PowerShellGet (included in PS v5, or download for v3/v4 via the gallery link)

```powershell
# One time only install:
Install-Module AtlassianPS.Configuration -Scope CurrentUser

# Check for updates occasionally:
Update-Module AtlassianPS.Configuration
```

### Usage

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

You can find the full documentation on our [homepage](https://atlassianps.org/docs/AtlassianPS.Configuration) and in the console.

### Contribute

Want to contribute to AtlassianPS? Great!
We appreciate [everyone](https://atlassianps.org/#people) who invests their time to make our modules the best they can be.

Check out our guidelines on [Contributing] to our modules and documentation.

## Useful links

* [Source Code]
* [Latest Release]
* [Submit an Issue]
* [Contributing]
* How you can help us: [List of Issues](https://github.com/AtlassianPS/AtlassianPS.Configuration/issues?q=is%3Aissue+is%3Aopen+label%3Aup-for-grabs)

## Disclaimer

Hopefully this is obvious, but:

> This is an open source project (under the [MIT license]), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.

<!-- reference-style links -->
  [AtlassianPS]: https://atlassianps.org/
  [PowerShell Gallery]: https://www.powershellgallery.com/
  [Source Code]: https://github.com/AtlassianPS/AtlassianPS.Configuration
  [Latest Release]: https://github.com/AtlassianPS/AtlassianPS.Configuration/releases/latest
  [Submit an Issue]: https://github.com/AtlassianPS/AtlassianPS.Configuration/issues/new
  [MIT license]: https://github.com/AtlassianPS/AtlassianPS.Configuration/blob/master/LICENSE
  [Contributing]: http://atlassianps.org/docs/Contributing

<!-- [//]: # (Sweet online markdown editor at http://dillinger.io) -->
<!-- [//]: # ("GitHub Flavored Markdown" https://help.github.com/articles/github-flavored-markdown/) -->
