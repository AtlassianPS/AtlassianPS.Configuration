---
Module Name: AtlassianPS.Configuration
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/about/authentication.html
---
# about_AtlassianPS_Authentication

## SHORT DESCRIPTION

Named connections, explicit authentication and non-secret profiles for adopting AtlassianPS modules.

## LONG DESCRIPTION

This experimental Configuration candidate supplies the shared connection runtime for JiraPS adoption.
ConfluencePS and JiraAgilePS keep their existing authentication workflows until their separate ports.
A local reusable connection can use stateless token authentication; it does not necessarily create a server-side cookie login.

### Authentication inputs

Username/password uses PSCredential.
Jira Cloud uses an email address with ApiToken for Basic authentication.
Supported Data Center products use PersonalAccessToken for Bearer authentication without a dummy username.
Product adapters decide which methods their APIs support.
Anonymous access must be requested explicitly.

Token parameters accept a nonempty string or SecureString on the same parameter.
A CI secret variable can be passed directly.
For an interactive secret, use Read-Host -AsSecureString.
An already-installed vault's Get-Secret output can supply a SecureString; no secret-management module is required.

```powershell
$token = Read-Host 'Jira API token' -AsSecureString
# Supply $token and your email to the adopting product's Connect command.
# In CI, use the same parameter with $env:JIRA_API_TOKEN.
```

The runtime owns copies of retained SecureStrings and does not dispose caller-owned values.
SecureString limits accidental exposure; code running in the same process can still access secrets.
String acceptance does not erase history, tracing or prior string copies.
Basic authentication encodes email and token as base64; HTTPS protects transport.
Diagnostics, display properties and profile export exclude authentication.

### Selection and lifetime

A successful first connection becomes its product's default.
Opening another leaves that default unchanged unless Default is requested.
Select chooses an existing connection without HTTP or configuration writes.
Explicit Connection or ConnectionName selects one operation and leaves the default unchanged.
The two selectors are mutually exclusive.
Names are case insensitive within a product; runtime IDs are unique across products.

Disconnect removes local state and invalidates retained handles.
Removing a default does not promote another connection.
Disconnect does not revoke tokens or log out unrelated jobs.
Connections belong to one runspace; establish a new connection in another job or process.
Unloading the shared runtime invalidates its handles.
Generic serialization cannot save or transfer a live connection.

### One-off authentication

Explicit authentication overrides create an isolated request context.
They retain the selected endpoint and inherit no cookies or identity-sensitive caches.
An API-token override supplies both its own email and token.
Empty explicit values fail instead of falling back to the stored identity.
The stored connection remains unchanged after success or failure.
Standalone endpoint requests do not register a connection or change a default.

Supply authentication through the product parameters.
Injected Authorization/Cookie headers and low-level credential, certificate or default-credential settings are unsupported alternate identities.
Remove conflicting global request defaults and use the supported product parameters.

### Saved profiles

Saved profiles contain only approved non-secret endpoint settings.
Loading a profile does not sign in.
Connect uses the profile's endpoint and the authentication supplied by the caller.
Live defaults and credentials are never persisted.
Portable JSON export has SchemaVersion 1 and allowlisted Id, Name, Uri and Type fields.
Saved and exported profiles cannot contain headers or certificates.
Import validates the complete document before changing profiles.

### Supported flows

This delivery does not implement browser OAuth, SSO, refresh-token management or automatic token renewal.
Check the adopting product's help for endpoint discovery, scopes and deployment-specific support.

## SEE ALSO

[about_JiraPS_Authentication](https://atlassianps.org/docs/JiraPS/about/authentication.html)

[Get-AtlassianConnection](https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-Connection/)

## Pipeline cancellation

Temporary request contexts are disposed after normal completion and errors inside the command.
The commands use lifecycle blocks compatible with Windows PowerShell 5.1, which has no script-function cleanup block for upstream pipeline failures or cancellation.
In that case, unreferenced secure secret copies are reclaimed by .NET; removing AtlassianPS.Configuration also disposes any retained temporary contexts.
Cancellation therefore does not guarantee immediate disposal.
