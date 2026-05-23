# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/),
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Improvements

- Migrated `Tools/setup.ps1` to shared `AtlassianPS.Standards` bootstrap/dependency commands with synchronized ScriptAnalyzer settings.
- Migrated `Tools/update.dependencies.ps1` to shared `AtlassianPS.Standards\Update-AtlassianPSDependencyReference` with `ShouldProcess` and fail-fast behavior.
- Aligned workflow setup pins and build/release standards version references to `AtlassianPS.Standards` `0.1.6`.
- Added regression coverage for setup/update delegation and cross-surface standards version consistency.
- Aligned build lint/publish tasks with JiraPS north-star shared helpers (`Invoke-AtlassianPSLint`, `Publish-AtlassianPSModuleRelease`, `New-AtlassianPSModulePackage`) and updated release workflow to call `Invoke-Build -Task Publish`.
- Added release changelog extraction to publish workflow and attached changelog body to the GitHub release.
- Wired `changelog-to-release` to `./.github/changelog.configuration.json` for JiraPS-parity release note rendering.
- Added `PrivateData.PSData.Prerelease` to the module manifest and regression checks so release publish/version tasks cannot fail on missing prerelease metadata.
- Removed smoke and placeholder integration test surfaces to keep this repository focused on unit/build validation.
- Removed build-time `ModuleVersion` mutation from `UpdateManifest`; release version updates now remain publish-scoped through `SetVersion`.

### Changed

- Added a dedicated shared runtime helper surface in `Public/SharedRuntime` and `Private/SharedRuntime`.
- Moved shared runtime helper implementations from `AtlassianPS.Standards` into `AtlassianPS.Configuration` to keep standards tooling-focused.

## 0.2 - 2018-10-03

### Changed

- Configuration is now persisted to disk with every change to it.

### Removed

- `Export-Configuration`

## 0.1 - 2018-07-17

This is a **Pre-Release**

This version the first pre-release version.
This release enables the development of the first integrations with other
modules.
Once the modules successfully implement this, it will be released with version
1.0.

<!-- Template
## x.x - YYYY-MM-DD

### FEATURES

### IMPROVEMENTS

### BUG FIXES
-->
