---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/New-ConnectionContext/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/New-ConnectionContext/
---
# New-ConnectionContext

## SYNOPSIS

Create an unregistered context for product-adapter validation.

## SYNTAX

### __AllParameterSets

```powershell
New-AtlassianConnectionContext [-Name <String>] -Product <String> -BaseUri <Uri> [-SiteUri <Uri>] [-CloudId <String>] [-Credential <PSCredential>] [-EmailAddress <String>] [-ApiToken <Object>] [-PersonalAccessToken <Object>] [-Anonymous] [<CommonParameters>]
```

## DESCRIPTION

Create an unregistered context for product-adapter validation.

This is a module integration API.
Use the product Connect command for ordinary sign-in.

## EXAMPLES

### EXAMPLE 1

```powershell
$candidate = New-AtlassianConnectionContext -Name example -Product Jira -BaseUri https://jira.example.com -Anonymous
$candidate.Dispose()
```

Create and discard an unregistered candidate. Product adapters validate before registration.

## PARAMETERS

### -Name

Friendly name, compared without case sensitivity within a product.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product

Product that owns this connection, such as Jira.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUri

Absolute HTTP(S) API product endpoint, without query, fragment or user information.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: None

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteUri

Optional browser site URI. It can differ from the resolved API endpoint.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloudId

Optional non-secret Cloud site identifier resolved by the product adapter.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Username and password as PSCredential. An explicit empty credential is invalid.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress

Cloud account email. Each API-token input must supply its own email.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Email

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiToken

Cloud API token as a nonempty string or SecureString. Requires EmailAddress.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PersonalAccessToken

Data Center personal access token as a nonempty string or SecureString.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: PAT, BearerToken

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Anonymous

Explicit anonymous authentication, when supported by the product endpoint.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

Supports the standard PowerShell common parameters.

## INPUTS

## OUTPUTS

### AtlassianPS.Connection

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/New-ConnectionContext/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
