# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/),
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## v0.2.7 - 2026-08-21

* Fixed automatic publishing to install the tested module's declared dependencies before calling `Publish-Module`. `v0.2.6` was not published; its changes are included in this release.

## v0.2.6 - 2026-08-21

### Improvements

- Added `-WhatIf` and `-Confirm` support to mutating configuration and server configuration commands.
- Migrated `Tools/setup.ps1` to shared `AtlassianPS.Standards` bootstrap/dependency commands with synchronized ScriptAnalyzer settings.
- Migrated `Tools/update.dependencies.ps1` to shared `AtlassianPS.Standards\Update-AtlassianPSDependencyReference` with `ShouldProcess` and fail-fast behavior.
- Aligned workflow and build dependencies with `AtlassianPS.Standards` `0.1.15`.
- Added regression coverage for setup/update delegation and cross-surface standards version consistency.
- Aligned release artifact creation and validation with shared `AtlassianPS.Standards` helpers.
- Made `CHANGELOG.md` the release-notes source for both PSGallery metadata and GitHub releases.
- Removed smoke and placeholder integration test surfaces to keep this repository focused on unit/build validation.
- Kept normal builds version-neutral while release metadata commits stamp the planned source version.

### Changed

- Added a dedicated shared runtime helper surface in `Public/SharedRuntime` and `Private/SharedRuntime`.
- Added `Write-VerboseMessage` as a public shared runtime helper for formatted verbose output without shadowing PowerShell's built-in `Write-Verbose`.
- Moved shared runtime helper implementations from `AtlassianPS.Standards` into `AtlassianPS.Configuration` to keep standards tooling-focused.

### Fixed

- Preserved in-memory server sessions while exporting sanitized configuration.
- Fixed server add/remove/update edge cases around duplicate names, pipeline input, URI validation, and empty server lists.
- Protected the internal `ServerList` key from generic configuration mutation while keeping `Message` configurable.
- Corrected first-use and command documentation for server configuration commands.
* Added automatic releases for reviewed contributor pull requests using the exact module artifact validated by CI.

## v0.2.5 - 2019-03-06

### Fixed

- Fixed test certificate generation behavior when certificate generation is available.

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
