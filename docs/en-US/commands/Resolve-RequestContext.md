---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-RequestContext/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Resolve-RequestContext/
---
# Resolve-RequestContext

## SYNOPSIS

Resolve a connection or standalone request with isolated authentication.

## SYNTAX

### __AllParameterSets

```powershell
Resolve-AtlassianRequestContext [-Product] <string> [[-RequestContext] <AtlassianPS.Connection>] [[-Connection] <AtlassianPS.Connection>] [[-ConnectionName] <string>] [[-BaseUri] <uri>] [[-Credential] <pscredential>] [[-EmailAddress] <string>] [[-ApiToken] <Object>] [[-PersonalAccessToken] <Object>] [-Anonymous] [<CommonParameters>]
```

## DESCRIPTION

Resolve a connection or standalone request with isolated authentication.

This is a module integration API.
Use the product Connect command for ordinary sign-in.

## EXAMPLES

### EXAMPLE 1

```powershell
$context = Resolve-AtlassianRequestContext -Product Jira -BaseUri https://jira.example.com -Anonymous
$context.Dispose()
```

Create a standalone context without selecting a default.

## PARAMETERS

### -Product

Product that owns this connection, such as Jira.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestContext

Previously resolved context to reuse for the requested product.
Cannot be combined with connection selectors or authentication parameters.
Invalid, disconnected, or foreign contexts are rejected.

```yaml
Type: Connection
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Connection

Live connection object from this shared runtime.
Removed and deserialized handles are rejected.

```yaml
Type: Connection
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConnectionName

Friendly name of an active connection for the requested product.
It is not a URL or profile name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
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

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Username and password as PSCredential.
An explicit empty credential is invalid.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress

Cloud account email.
Each API-token input must supply its own email.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiToken

Cloud API token as a nonempty string or SecureString.
Requires EmailAddress.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: 7
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
Position: 8
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

### AtlassianPS.Connection

## OUTPUTS

### AtlassianPS.Connection

## NOTES

Live connections are local to one runspace and are never saved as profiles.

## RELATED LINKS

[Online Version](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-RequestContext/)

[Shared authentication](https://atlassianps.org/docs/AtlassianPS.Configuration/about/authentication.html)
