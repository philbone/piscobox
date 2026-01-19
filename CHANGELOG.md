# Changelog

All notable changes to this project are documented in this file.

The format is based on "Keep a Changelog" and follows Semantic Versioning:
https://keepachangelog.com/en/1.0.0/

## [Unreleased]

### Added
- CLI: `piscobox site delete` — New command to remove a site VirtualHost and related configuration.
  - Disables the vhost (`a2dissite`), creates a timestamped backup of the site `.conf`, removes the vhost file from `/etc/apache2/sites-available`, attempts to clean generated multiphp alias blocks from `/etc/apache2/conf-enabled/piscobox-multiphp-aliases.conf`, and removes entries from `/vagrant/.piscobox-hosts`.
  - Interactive prompt (default: Yes) to delete the site's document root; supports `--doc-root`, `--no-reload`, and `--force` flags.
  - Safety checks to refuse deletion of common dangerous paths (e.g. `/`, `/var`, `/var/www`, `/var/www/html`).
  - (Implemented in provision/cli/piscobox-cli.sh; merged via PR #81)

- CLI: `piscobox site set-php` — New command to change the PHP-FPM version used by an existing site.
  - Validates PHP-FPM socket presence, updates the `SetHandler` socket in the vhost and updates multiphp alias configuration.
  - Supports interactive and non-interactive modes and flags: `--doc-root`, `--no-reload`, `--force`.
  - (Implemented and merged via PR #79 / #73)

- Script: `piscobox-sync-hosts.sh` — Idempotent helper to synchronize VM-managed host entries into the host's `/etc/hosts` safely (prevents duplicates and preserves existing entries).
  - (Implemented and merged via PR #72)

- Docs: README updated with a CLI commands table, detailed behavior & safety notes for `site delete` and `site set-php`, and full examples for interactive and non-interactive usage.

### Changed
- CLI help (`show_help()`) updated to include `site delete` and improved usage/flags for `site set-php`.
- CLI: enhancements to piscobox-cli to support multi-PHP setups and multiphp alias management (improved VirtualHost creation, socket validation and multiphp alias updates).
- Docs: multiple README improvements describing Multi-PHP support, demos installation/uninstallation, and local domain setup.

### Fixed
- Fixed/adjusted the document root handling in `site create` to avoid incorrect paths.
- Removed bundled `demos` directory from Git tracking and improved demo install/uninstall flow.
- Recovered legacy CLI commands where appropriate (e.g. `mysql login`, `install demo-php`, `uninstall demo-php`) to preserve commonly used workflows.
- Misc CLI compatibility/cleanup for legacy commands.

### Security / Safety
- `site delete` and `site set-php` include safety checks (backups before changing/removal, refusal to remove dangerous paths, validation of PHP sockets).
- Host-sync script replaces ad-hoc host file modifications with a safer, idempotent approach to minimize accidental host file corruption.

### References / notable PRs
- PR #81 — feature(cli): add `site delete` command; update help and README
- PR #79 — feature(cli): add `site set-php` command
- PR #72 — Feature/piscobox cli upgrade / add piscobox-sync-hosts.sh
- PR #63 / multi-PHP support PRs — Apache multi-PHP and alias support
- Various docs and demo-related PRs and fixes (see repo commit history)

---

## Suggested release procedure
1. When ready to release, rename `Unreleased` to the version and date, e.g.:
   ## [0.1.0] - 2026-01-19
2. Add or adjust entries under Unreleased to reflect any additional changes.
3. Tag the release in git using the semantic version (e.g. `git tag -a v0.1.0 -m "v0.1.0"`).

## Contributing
- Add entries to `Unreleased` for user-visible changes in future PRs.
- Group entries under Added, Changed, Fixed, or Security and keep text concise.