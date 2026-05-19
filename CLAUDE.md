# Claude Code Entry Point

Follow canonical guidance in this order:

1. [AGENTS.md](AGENTS.md)
2. [.github/ai-context/powershell-rules.md](.github/ai-context/powershell-rules.md)

If files disagree, `AGENTS.md` wins.

## Hard Requirements

1. Preserve persisted configuration compatibility (`Configuration.psd1`, `Message`, `ServerList`).
2. Use existing wrappers/helpers (`Save-Configuration`, private `Invoke-WebRequest`, `Import-MqcnAlias` patterns).
3. Keep changes test-backed in `Tests/`.
4. Run `Invoke-Build -Task Build, Test` before completion (and `Lint` for full local validation).

## Key Paths

- Module code: `AtlassianPS.Configuration/Public/`, `AtlassianPS.Configuration/Private/`
- Module bootstrap/schema wiring: `AtlassianPS.Configuration/AtlassianPS.Configuration.psm1`
- Build script: `AtlassianPS.Configuration.build.ps1`
- Tests: `Tests/**/*.ps1`
- Help docs: `docs/en-US/commands/*.md`, `docs/en-US/about_*.md`
