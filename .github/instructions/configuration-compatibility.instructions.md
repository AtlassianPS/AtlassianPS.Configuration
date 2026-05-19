---
applyTo: "**/*.ps1"
---

# PowerShell File Rules (GitHub Copilot)

This file applies to all `.ps1` files. It references shared rules.

**Canonical source**: [.github/ai-context/powershell-rules.md](../ai-context/powershell-rules.md)

## Quick Reference

1. **Persisted compatibility** — preserve `Configuration.psd1` key semantics, especially `Message` and `ServerList`.
2. **Persistence flow** — use `Get-Configuration`, `Set-Configuration`, `Remove-Configuration`, and `Save-Configuration`; avoid ad-hoc config file writes.
3. **Wrapper usage** — use existing wrappers/helpers (`Save-Configuration`, private `Invoke-WebRequest`, `Import-MqcnAlias` patterns).
4. **Tests required** — during iteration run targeted `Invoke-Pester` when possible (for example `Invoke-Pester -Path 'Tests/Functions/Get-Configuration.Unit.Tests.ps1'`).
5. **Final validation** — run `./Tools/setup.ps1`, `Invoke-Build -Task Lint`, and `Invoke-Build -Task Build, Test`.
6. **CI path filters** — instruction-only changes may be skipped by CI; run local validation and report exact command outcomes.

For full rules, read `.github/ai-context/powershell-rules.md`.
