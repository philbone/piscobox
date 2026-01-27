# Pisco Box 🥂

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.2+-blue.svg)](https://www.vagrantup.com)
[![Debian 12](https://img.shields.io/badge/Debian-12-C70E37.svg)](https://www.debian.org/releases/bookworm/)
[![Apache 2.4](https://img.shields.io/badge/Apache-2.4-A64D79.svg)](https://httpd.apache.org/docs/2.4/new_features_2_4.html)
[![PHP Multi](https://img.shields.io/badge/PHP-Multi--Version-8892BF.svg)](https://www.php.net)
[![MariaDB](https://img.shields.io/badge/MariaDB-latest-A26D37.svg)](https://mariadb.com/docs/release-notes)
[![PostgreSQL 16](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org)
[![Redis 7.2+](https://img.shields.io/badge/Redis-7.2+-DC382D.svg)](https://redis.io)
[![Memcached 1.6+](https://img.shields.io/badge/Memcached-1.6+-blue.svg)](https://memcached.org)
[![phpMyAdmin](https://img.shields.io/badge/phpMyAdmin-5.2.x-orange.svg)](https://www.phpmyadmin.net)
[![pgAdmin](https://img.shields.io/badge/pgAdmin-4-blue.svg)](https://www.pgadmin.org)
[![Redis Commander](https://img.shields.io/badge/Redis%20Commander-0.9.x-D82C20.svg)](https://github.com/joeferner/redis-commander)
[![Composer 2.x](https://img.shields.io/badge/Composer-2.x-89552D.svg)](https://getcomposer.org)

> **Version:** 0.3.0  
> **Repository:** https://github.com/philbone/piscobox

---

**A modern LAMP stack for web developers based on Debian Bookworm**

Pisco Box is a ready-to-use Vagrant box built on Debian, providing a complete LAMP development environment with Apache, multiple PHP versions, MariaDB, PostgreSQL, Redis and essential tools for modern web development.

---

## 💡 Why Pisco Box?

Unlike generic LAMP boxes, **Pisco Box** provides:

- Native **multi-PHP** support
- Automated **VirtualHost + domain management**
- Full **Xdebug 3** integration
- Safe, developer-friendly **CLI**
- Built-in **backups and safety checks**

---

## ✨ Features

- Debian Bookworm 64-bit
- Apache 2.4 + PHP-FPM
- PHP: 8.4, 8.3, 8.0, 7.4, 7.0, 5.6
- MariaDB, PostgreSQL 16, Redis 7.2+ and Memcached 1.6+
- Database Management: phpMyAdmin, pgAdmin and Redis Commander
- Development Tools: Git, Vim, Curl, Wget, and more
- Time Zone: UTC, locale UTF-8
- Synchronized Directories: Seamless host ↔ VM file sharing
- Local Domains Assistant: Automates `/etc/hosts` updates
- CLI Tool (`piscobox`): Simplifies common development tasks

**Dependencies:**
* [Vagrant 2.2+](https://www.vagrantup.com/downloads)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (recommended), or Parallels / VMware

---

## 🧩 Multi-version Xdebug Integration

* Automated installation and configuration of **Xdebug 3.x** for all supported PHP versions  
* Legacy support for **Xdebug 2.x** (for PHP ≤ 7.1)
* Auto-detection of PHP version and per-version config in `/etc/php/<ver>/mods-available/xdebug.ini`
* Debugging works across all PHP-FPM pools and CLI contexts
* Default dev-optimized settings:
  * Remote debugging via port `9003`
  * Auto-discovery of host (`10.0.2.2`)
  * Logs stored at `/var/log/xdebug.log`
* Works out-of-the-box with **VS Code**, **PhpStorm**, and other IDEs

---

## 🚀 Quick Start

```bash
git clone https://github.com/philbone/piscobox.git
cd piscobox
vagrant up
```

### Access

**Web Access:**
* Main URL: [http://localhost:8080](http://localhost:8080)
* With IP: [http://192.168.56.110](http://192.168.56.110)
* With hostname: [http://piscobox.local](http://piscobox.local)

> ⚠️ **Port conflicts?**  
> If port `8080` is in use, edit your `Vagrantfile`:
> ```ruby
> config.vm.network "forwarded_port", guest: 80, host: 8081
> ```
> Then `vagrant reload` and visit [http://localhost:8081](http://localhost:8081)

> 💡 **IP conflicts?**  
> Default IP `192.168.56.110` is set in the `Vagrantfile`.  
> You can change it if another VM uses the same subnet:
> ```ruby
> config.vm.network "private_network", ip: "192.168.56.120"
> ```
> Then `vagrant reload` and visit [http://192.168.56.120](http://192.168.56.120)

### SSH Access

```bash
vagrant ssh
```
Or connect via an external SSH client:

```
Host: locahost or 127.0.0.1
User: vagrant
Password: vagrant
Key: .vagrant/machines/default/virtualbox/private_key
```
```bash
ssh -i ./.vagrant/machines/default/virtualbox/private_key -p 2222 vagrant@127.0.0.1
```

---

## ✅ Quick Verification (Smoke Test)

After running `vagrant up`, verify your setup:

1. Visit [http://localhost:8080](http://localhost:8080) → Apache2 Debian Default Page
1. Visit [http://localhost:8080/piscoweb](http://localhost:8080/piscoweb) → Pisco Box index page
1. Visit [http://localhost:8080/piscoweb/hello-world.php](http://localhost:8080/piscoweb/hello-world.php) → Pisco Box Hello World! 
1. Visit [http://localhost:8080/info.php](http://localhost:8080/info.php) → PHP info
1. Visit [http://localhost:8080/info-xdebug.php](http://localhost:8080/info-xdebug.php) → Xdebug info
1. Visit [http://localhost:8080/phpmyadmin](http://localhost:8080/phpmyadmin) → phpMyAdmin dashboard
1. Visit [http://localhost:8080/pgadmin4](http://localhost:8080/pgadmin4) → postgresql dashboard
1. Visit [http://localhost:8080/redis](http://localhost:8080/redis) → Redis Commander dashboard
1. Run `piscobox mysql login` → connects to MariaDB as `piscoboxuser`
1. Run `sudo mysql` → connects to MariaDB as `root`
1. Run `piscobox site create` → creates and serves `http://mysite.local`  
1. Inside VM: `php -v` → multiple PHP versions  
1. Run `sudo php -m | grep xdebug` → Xdebug active  

---

## 🧪 Demo & Verification

Pisco Box includes a [Hello World](http://localhost:8080/piscoweb/hello-world.php) view to verify:

* Apache is running  
* PHP configured correctly  
* MariaDB connectivity works

You can also test Xdebug at: [http://piscobox.local/info-xdebug.php](http://piscobox.local/info-xdebug.php)

---

# 🖥️ Piscobox CLI

Piscobox includes a built-in CLI to simplify common tasks.

Usage:
```bash
piscobox [command] [options]
```

### Commands

| Command | Description | Flags / Notes |
|----------|-------------|---------------|
| `site create` | Create a new VirtualHost and PHP site. | Interactive |
| `site delete <site>` | Delete a VirtualHost (with safety checks and backups). | `--doc-root`, `--force`, `--no-reload` |
| `site set-php <site> <ver>` | Change PHP-FPM version used by a site. | `--doc-root`, `--no-reload`, `--force` |
| `site available-cleanup <mode>` | Clean `.conf.bak` files in `/etc/apache2/sites-available`. | `-normal`, `--purge` |
| `hosts-sync` | Sync `/etc/hosts` on your host. | — |
| `install demo-php` | Install included PHP demos. | — |
| `uninstall demo-php` | Uninstall PHP demos. | — |
| `mysql login` | Access MySQL as `piscoboxuser`. | — |
| `help` | Show CLI help. | — |

Behavior highlights:
- Every `.conf` is backed up before modification.
- Dangerous paths (`/`, `/var`, `/var/www`, etc.) are protected.
- Backups named as `mysite.conf.bak-YYYYMMDD-HHMMSS`.

---

## 📁 Project Structure

```bash
pisco-box/
├── doc/                    
├── extra_data/             
├── provision/              
├── public_html/            
├── utils/                  
├── .piscobox-hosts         
├── LICENSE
├── piscobox-sync-hosts.sh  
├── README.md
└── Vagrantfile
```

---

## 🗄️ Database Configuration

### MariaDB (MySQL)
**Default credentials:**

| Parameter | Value           |
|-----------|-----------------|
| User      | `piscoboxuser`  |
| Password  | `DevPassword123`|
| Database  | `piscoboxdb`    |
| Host      | `localhost`     |

> 💡 **phpMyAdmin** is available at  
> [http://localhost:8080/phpmyadmin](http://localhost:8080/phpmyadmin)  
>  
> Database creation and administrative tasks are intentionally handled via the `piscobox` CLI.

### Examples

Command Line:

```bash
sudo mysql
mariadb -u piscoboxuser -p
# Password: DevPassword123
```

PHP:
```php
$mysqli = new mysqli("localhost", "piscoboxuser", "DevPassword123", "piscoboxdb");
```

### PostgreSQL 16
PostgreSQL does **not** use a `root` user. Administrative access is provided by the `postgres` role.

**Default credentials:**

| Parameter | Value           |
|-----------|-----------------|
| User      | `piscoboxuser`  |
| Password  | `DevPassword123`|
| Database  | `piscoboxdb`    |
| Host      | `localhost`     |

Administrative access (superuser):
```bash
$ sudo -u postgres psql
```
Development access:
```bash
$ psql -U piscoboxuser -d piscoboxdb
```
These commands provide sufficient access for users familiar with PostgreSQL. Additional management commands will be added to the piscobox CLI in future releases.

### Redis 7.2+
Redis is installed from the official Redis repository and enabled by default.

**Default configuration:**

| Parameter       | Value                       |
| --------------- | --------------------------- |
| Host            | `127.0.0.1`                 |
| Port            | `6379`                      |
| Auth            | Disabled (development only) |
| Max memory      | `256mb`                     |
| Eviction policy | `allkeys-lru`               |

Test Redis:
```bash
$ redis-cli
PING
```
---

### Redis Commander

Redis Commander is included as a web-based management UI for Redis.

**Access:**
- http://localhost:8080/redis

**Notes:**
- Redis Commander runs locally and is exposed via Apache reverse proxy.
- During provisioning, npm may emit deprecation warnings related to upstream dependencies.
  These warnings are expected and safe to ignore in the context of local development.

---

### Memcached 1.6+

Memcached is installed and enabled by default for local development.

**Default configuration:**

| Parameter | Value |
|----------|------|
| Host     | `127.0.0.1` |
| Port     | `11211` |
| Memory   | `128 MB` |
| Auth     | Disabled (development only) |

#### Test Memcached (CLI)

```bash
echo stats | nc 127.0.0.1 11211
```

### Test Memcached (PHP)

> Memcached is provided via the native PHP extension (php-memcached).
> No Composer dependency is required.

```bash
$ php -dxdebug.mode=off -r '
$m = new Memcached();
$m->addServer("127.0.0.1", 11211);
$m->set("ping", "pong");
echo $m->get("ping") . PHP_EOL;
'
```
---

## 🛠️ Technical Details

### PHP Configuration

* Per-version PHP-FPM (via mod_proxy_fcgi)
* Default memory limit: 512MB
* Upload limit: 100MB
* `display_errors` = On (development mode)

Apache automatically routes each site to its configured PHP-FPM version.

---

### 🔍 Xdebug Configuration Example (PHP 8.3)

```ini
zend_extension=xdebug.so

[xdebug]
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.client_host=10.0.2.2
xdebug.client_port=9003
xdebug.discover_client_host=1
xdebug.log=/var/log/xdebug.log
xdebug.log_level=7
```

---

### Apache Modules Enabled

* proxy_fcgi  
* setenvif  
* rewrite  
* headers  
* expires  
* include  

---

### Service Management

```bash
# Restart Apache
sudo systemctl restart apache2

# Restart PHP-FPM (specific version)
sudo systemctl restart php8.3-fpm

# View logs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/piscobox-error.log
```

---

## 🔧 Customization

### Configure Hostnames With CLI

```bash
piscobox site create
```

Follow prompts:
1. Site name → `mysite`
2. PHP version → `8.3`
3. Document root → `/var/www/html/mysite`

Your site will be available at:
* [http://mysite.local](http://mysite.local)  
* or [http://192.168.56.110/mysite/](http://192.168.56.110/mysite/)

---

### Sync Hostnames (macOS/Linux/Windows)

Pisco Box tracks local domains in:
```
vagrant/.piscobox-hosts
```

To sync with your host:
```bash
./piscobox-sync-hosts.sh
```

This safely updates `/etc/hosts`, removing old entries and adding new ones.

---

### Or, Configure Local Hostnames Manually

**macOS/Linux**
```bash
sudo nano /etc/hosts
# Add:
127.0.0.1 piscobox.local
```

**Windows**
```text
# Edit C:\Windows\System32\drivers\etc\hosts as Administrator
127.0.0.1 piscobox.local
```
---

## 🐛 Troubleshooting (Quick Guide)

### 🧩 PHP not executing
```bash
ls /run/php/
sudo systemctl status php8.3-fpm
sudo a2enmod proxy_fcgi && sudo systemctl reload apache2
```

### 🗄️ Database connection issues
```bash
sudo systemctl status mariadb
mysql -u piscoboxuser -p
piscobox mysql login
```

### 🔄 Files not syncing
```bash
vagrant reload
sudo chown -R vagrant:vagrant /vagrant
```

### 🌐 Local domain not resolving
```bash
./piscobox-sync-hosts.sh
# Then flush DNS cache if needed
```

### 🔴 Redis Commander not loading

```bash
sudo systemctl status redis-commander
sudo systemctl restart redis-commander
sudo systemctl reload apache2
```

---

## ⚠️ Security Notice

Local development only. Do not use in production.

---

## 📄 License

MIT License
