# Changelog

All notable changes to this project are documented in this file.

The format is based on "Keep a Changelog" and follows Semantic Versioning:  
https://keepachangelog.com/en/1.0.0/

---
## [0.3.0] - 2026-03-17

### Added

#### Core Services
- PostgreSQL 16 support
- Redis 7.2+ installation and configuration
- Memcached 1.6+ support
- Beanstalkd 1.12 integration
- SQLite 3.46+ support

#### Developer Tooling
- Node.js 18 LTS (with npm)
- Built-in `piscobox` CLI for site and environment management

#### Web Interfaces
- pgAdmin 4 integration
- Redis Commander integration (web UI)
- phpMemcachedAdmin integration
- SQLite Web integration
- Beanstalk Console integration

#### Platform Features
- Native multi-PHP support (PHP 5.6 → 8.4 via PHP-FPM)
- Full multi-version Xdebug support (Xdebug 2.x and 3.x)
- Web dashboards exposed via Apache reverse proxy (e.g. /redis, /pgadmin4)

### Changed
- Centralized PHP version management using global configuration (`PHP_VERSIONS`)
- Improved provisioning robustness with safe configuration loading
- Refactored provisioning scripts for consistency and maintainability
- Improved Xdebug CLI experience (logging to user HOME)
- Redis Commander systemd service hardened
- Improved provisioning stability and test coverage

### Fixed
- phpMyAdmin incorrectly detecting PHP 5.6
- `set_php_version` virtualhost resolution issues
- sed delimiter errors in CLI scripts
- CRLF compatibility issues in bash scripts (Windows environments)
- `.user.ini` unintended creation during provisioning
- php.ini strict behavior inconsistencies

### Notes
- Several internal improvements were made to CLI commands and provisioning flow for better stability and developer experience.
---

## [0.2.0] - 2026-01-19

### Added
- **Provisioning: `xdebug.sh` — Automated multi-version Xdebug installation and configuration**
  - Adds full support for **Xdebug 3.x** across all PHP versions installed in the box.
  - Automatically detects PHP version and applies the correct syntax (Xdebug 2.x for legacy PHP ≤7.1, Xdebug 3.x for modern PHP).
  - Creates and enables version-specific configuration files at `/etc/php/<ver>/mods-available/xdebug.ini`.
  - Configures default developer-friendly settings:
    - `xdebug.mode=debug`
    - `xdebug.start_with_request=yes`
    - `xdebug.client_host=10.0.2.2`
    - `xdebug.client_port=9003`
    - `xdebug.log=/var/log/xdebug.log`
  - Automatically restarts Apache and all PHP-FPM pools after installation.
  - Verifies Xdebug installation for each PHP version and summarizes results:
    ```
    ✓ Xdebug 3 active: 7.4 8.0 8.3 8.4
    ⚠ Legacy Xdebug detected: 5.6 7.0
    ```
  - Fully compatible with multi-PHP projects and IDEs like VS Code or PhpStorm.

- **Docs:**  
  - Updated `README.md` to include new **Xdebug integration** section:
    - Describes automated setup, compatibility, and verification steps.
    - Adds usage examples for testing via `test-xdebug.php`.
    - Lists Xdebug among supported technologies in badges and feature overview.

### Changed
- Improved provisioning workflow to ensure Xdebug installs cleanly alongside existing PHP-FPM services.
- Minor refinements to script output and status formatting for consistency with other provisioning scripts.

### Fixed
- Legacy compatibility issues handled automatically for PHP 5.6 and 7.0 (graceful fallback to older Xdebug syntax).
- Ensured creation of missing `/var/log/xdebug.log` directory to avoid initial log write warnings.

### References / notable PRs
- PR #92 — **feature(provision): add automated multi-version Xdebug installation**
- Related improvements in provisioning scripts and README documentation.

---

## [0.2.0] - 2026-01-18

### Added
- CLI: `piscobox site delete` — Remove site VirtualHost and configuration safely.
- CLI: `piscobox site set-php` — Change the PHP-FPM version for an existing site.
- Script: `piscobox-sync-hosts.sh` — Synchronize VM-managed host entries into host `/etc/hosts`.
- Docs: README extended with CLI command table, behavior, examples, and multi-PHP documentation.

### Changed
- Enhanced CLI help and improved multi-PHP alias management.
- Updated documentation for demos and local domain configuration.

### Fixed
- Document root handling, demo app flow, and backward compatibility of legacy commands.

### Security / Safety
- Added safety checks in `site delete` (prevent deletion of system paths).
- Host-sync script rewritten for idempotent and safe updates.

### References / notable PRs
- PR #81 — feature(cli): add `site delete` command  
- PR #79 — feature(cli): add `site set-php` command  
- PR #72 — feature(cli): add `piscobox-sync-hosts.sh`  
- PR #63 — multi-PHP and alias management support  

## [0.1.0] There is no changelog for this version.

---

## Suggested release procedure
1. When ready to release, rename `Unreleased` to the version and date, e.g.:
   ## [0.2.0] - 2026-01-19
2. Add or adjust entries under Unreleased to reflect any additional changes.
3. Tag the release in git using the semantic version (e.g. `git tag -a v0.2.0 -m "v0.2.0 - Multi-version Xdebug integration"`).

## Contributing
- Add entries to `Unreleased` for user-visible changes in future PRs.
- Group entries under Added, Changed, Fixed, or Security and keep text concise.

---