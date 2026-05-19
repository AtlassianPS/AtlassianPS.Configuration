# AtlassianPS.Configuration PowerShell Rules

This file captures practical coding/build/test rules shared across AI entry points.

## Build and Test Commands (run from repo root)

```powershell
./Tools/setup.ps1
Invoke-Build -Task Lint
Invoke-Build -Task Build, Test
```

Focused iteration command:

```powershell
Invoke-Pester -Path 'Tests/Functions/<FunctionName>.Unit.Tests.ps1'
```

Run full `Build, Test` before completion.

## Source Layout

- Public cmdlets: `AtlassianPS.Configuration/Public/*.ps1`
- Private helpers: `AtlassianPS.Configuration/Private/*.ps1`
- Module bootstrap/schema wiring: `AtlassianPS.Configuration/AtlassianPS.Configuration.psm1`
- Persisted defaults: `AtlassianPS.Configuration/Configuration.psd1`
- Build script: `AtlassianPS.Configuration.build.ps1`
- Docs/help sources: `docs/en-US/commands/*.md`, `docs/en-US/about_*.md`
- Tests: `Tests/**/*.ps1`

## Configuration Compatibility Rules

- Keep persisted key semantics backward compatible (`Message`, `ServerList`).
- Keep `ServerList` entries compatible with `[AtlassianPS.ServerData]`.
- Preserve metadata converter contracts used by `Import-Configuration` / `Export-Configuration`.
- Persist updates through `Save-Configuration` (which strips `ServerList[].Session` intentionally).
- Do not introduce direct ad-hoc writes to user configuration files.

## Wrapper and Helper Rules

- Prefer existing public/private config helpers over duplicate IO logic.
- Use private `Invoke-WebRequest` wrapper when module HTTP behavior is required.
- Maintain mockable module-qualified calls with `Import-MqcnAlias` where the pattern already exists.
- Use `WriteError` / `ThrowError` helpers for consistent error records.

## Coding Conventions

- Follow existing cmdlet and helper patterns.
- Add comments only for non-obvious constraints or decisions.
- Use `#ToDo:<Category>` markers for explicit technical debt tracking.
- Keep changes focused and avoid unrelated refactors.

## Documentation Conventions

- User-facing command documentation belongs in `docs/en-US/commands/*.md`.
- Include changelog updates for user-visible behavior changes.
