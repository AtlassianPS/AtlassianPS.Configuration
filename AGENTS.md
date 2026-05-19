# AI Instructions for AtlassianPS.Configuration

> **Canonical AI guidance for this repository.**
> `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, and `.cursor/rules/*.mdc` must stay aligned with this file.

## Non-Negotiable Rules

1. **Ship complete vertical slices**: code, tests, docs, and changelog updates move together.
2. **Do not finish on a red build**: run `Invoke-Build -Task Build, Test` at minimum before completion.
3. **Preserve persisted configuration compatibility**: do not break existing `Configuration.psd1` data.
4. **Use existing wrappers/helpers**: no ad-hoc config persistence or direct command bypasses.
5. **Validate behavior changes with tests**: update or add tests under `Tests/`.

## Repository Surfaces

- Module source: `AtlassianPS.Configuration/Public/*.ps1`, `AtlassianPS.Configuration/Private/*.ps1`
- Module bootstrap and schema wiring: `AtlassianPS.Configuration/AtlassianPS.Configuration.psm1`
- Persisted defaults: `AtlassianPS.Configuration/Configuration.psd1`
- Build entrypoint: `AtlassianPS.Configuration.build.ps1`
- Tests: `Tests/**/*.ps1`
- Help sources: `docs/en-US/commands/*.md`, `docs/en-US/about_*.md`

## Configuration Schema and Compatibility Requirements

- Keep top-level configuration keys compatible with existing installs, especially `Message` and `ServerList`.
- Keep `ServerList` entries compatible with `[AtlassianPS.ServerData]` serialization/deserialization.
- Preserve metadata converter contracts in `AtlassianPS.Configuration.psm1` (`AtlassianPSMessageStyle`, `AtlassianPSServerData`).
- Persist config only through `Save-Configuration`; it intentionally strips `ServerList[].Session` before export.
- Do not rename/remove persisted keys or change semantics without migration coverage and regression tests.

## Wrapper and Helper Requirements

- Use `Get-Configuration`, `Set-Configuration`, `Remove-Configuration`, and `Save-Configuration` for config IO flows.
- Use the module’s private `Invoke-WebRequest` wrapper for HTTP behavior that must stay cross-version compatible.
- Keep module-qualified command wrappers mockable via `Import-MqcnAlias` when following existing helper patterns.
- Use existing error helpers (`WriteError`, `ThrowError`) for consistent error records.

## Validation Commands (run from repo root)

```powershell
./Tools/setup.ps1
Invoke-Build -Task Lint
Invoke-Build -Task Build, Test
```

Recommended focused loop while iterating:

```powershell
Invoke-Pester -Path 'Tests/Functions/<FunctionName>.Unit.Tests.ps1'
```

## CI/CD References

- `.github/workflows/ci.yml` is the required quality gate.
- `.github/workflows/release.yml` publishes tagged releases.
