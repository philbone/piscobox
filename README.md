# PiscoBox 🥂

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.2+-blue.svg)](https://www.vagrantup.com)
[![Debian 12](https://img.shields.io/badge/Debian-12-C70E37.svg)](https://www.debian.org/releases/bookworm/)
[![Apache 2.4](https://img.shields.io/badge/Apache-2.4-A64D79.svg)](https://httpd.apache.org/docs/2.4/new_features_2_4.html)
[![PHP Multi](https://img.shields.io/badge/PHP-Multi--Version-8892BF.svg)](https://www.php.net)
[![MariaDB](https://img.shields.io/badge/MariaDB-latest-A26D37.svg)](https://mariadb.com/docs/release-notes)
[![Composer 2.x](https://img.shields.io/badge/Composer-2.x-89552D.svg)](https://getcomposer.org)

**A modern LAMP stack for web developers based on Debian Bookworm**

PiscoBox is a ready-to-use Vagrant box built on Debian, providing a complete LAMP development environment with Apache, multiple PHP versions, MariaDB, and essential tools for modern web development.

## ✨ Features

* **Operating System**: Debian Bookworm 64-bit
* **Web Server**: Apache 2.4 with PHP-FPM integration
* **PHP (Multi-Version Support)**:

  * Multiple PHP versions running simultaneously
  * Available versions: **8.4, 8.3, 8.0, 7.4, 7.0, 5.6**
  * Ideal for maintaining and developing multiple projects with different PHP requirements
* **Database**: MariaDB Server & Client
* **Package Manager**: Composer 2.x for PHP dependencies
* **Development Tools**: Git, Vim, Curl, Wget, and more
* **Time Zone**: UTC with UTF-8 locale configuration
* **Synchronized Directories**: Easy file sharing between host and VM
* **Local Domains Assistant**:

  * Script to assist in the creation of local domains
  * Automatically updates `/etc/hosts` to register VirtualHosts created inside the VM
* **CLI Tool (`piscobox`)**:

  * Command-line utility to simplify common development tasks

## 🚀 Quick Start

### Prerequisites

* [Vagrant](https://www.vagrantup.com/downloads) (2.2+)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads), Parallels, or VMware

### Installation

```bash
git clone https://github.com/philbone/piscobox.git
cd piscobox
vagrant up
```

### Access

Once running, you can access your environment:

**Web Access:**

* Main URL: [http://localhost:8080](http://localhost:8080)
* With IP: [http://192.168.56.110](http://192.168.56.110)
* With hostname: [http://piscobox.local](http://piscobox.local) (requires hosts configuration)

### SSH Access:

```bash
vagrant ssh
```

## 🧪 Demo & Verification

PiscoBox includes a [Hello World](public_html/piscoweb/hello-world.php) view to quickly verify that the stack is working correctly.

This demo page confirms:

* Apache is running
* PHP is properly configured
* MySQL/MariaDB connectivity is working

Additionally, the project includes helper commands to install or remove **PHP and MySQL demo applications** for testing and experimentation.

## 🖥️ Piscobox CLI

PiscoBox ships with a built-in CLI tool to streamline daily tasks.

**Usage:**

```text
piscobox [command] [options]
```

**Available commands:**

* `site create` – Create a new VirtualHost and PHP site
* `hosts-sync` – Display instructions to sync `/etc/hosts` on your host
* `install demo-php` – Install the PHP demos
* `uninstall demo-php` – Uninstall the PHP demos
* `mysql login` – Direct access to MySQL as the user `piscoboxuser`
* `help` – Show help information

> The README documents the availability of these commands; detailed usage is provided via the CLI itself.

## 📁 Project Structure

```bash
pisco-box/
├── doc/            		# Documentation and collaboration
├── extra_data/     		# Extra data, backups (not web accessible)
├── provision/      		# Provisioning scripts
├── public_html/    		# Document root (synchronized with /var/www/html)
├── utils/          		# Workflow templates and utilities
├── .piscobox-hosts 		# The VM hosts that should be synchronized with the host machine
├── LICENSE
├── piscobox-sync-hosts.sh	# Safely synchronizes local /etc/hosts with VM site entries
├── README.md
└── Vagrantfile
```

## 🗄️ Database Configuration

### Credentials:

* User: `piscoboxuser`
* Password: `DevPassword123`
* Host: `localhost`
* Database: `piscoboxdb`

### Connection Examples

Command Line:

```bash
# As root
sudo mysql

# As database user
mariadb -u piscoboxuser -p
# Password: DevPassword123
```

### PHP

```php
$mysqli = new mysqli("localhost", "piscoboxuser", "DevPassword123", "piscoboxdb");
```

## 🛠️ Technical Details

### PHP Configuration

* Per-version PHP-FPM via Apache mod_proxy_fcgi
* Multiple PHP versions available simultaneously
* Default memory limit: 512MB
* Upload limit: 100MB
* Development settings: display errors enabled, E_ALL reporting

Apache automatically uses the right PHP version for each project,  
so you can run different PHP versions at the same time without conflicts.

### Apache Modules

Enabled modules include:

* proxy_fcgi
* setenvif
* rewrite
* headers
* expires
* include

### Useful Commands

Service Management:

```bash
# Restart Apache
sudo systemctl restart apache2

# Restart a specific PHP-FPM version
sudo systemctl restart php8.3-fpm

# View Apache logs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/piscobox-error.log
```

## 🔧 Customization

### Configure Local Hostnames Manually

To use `http://piscobox.local` instead of `http://localhost:8080` or `http://192.168.56.110`:

**On macOS/Linux:**

```bash
sudo nano /etc/hosts
# Add: 127.0.0.1 piscobox.local
```

**On Windows:**

```text
# Open C:\Windows\System32\drivers\etc\hosts as Administrator
# Add: 127.0.0.1 piscobox.local
```

> Note: PiscoBox includes a helper script and CLI command to assist with this process👇

### Configure Local Hostnames With CLI

Piscobox lets you create isolated PHP sites, each with its own domain (e.g. mysite.local) and PHP version.

You can easily create one using the built-in CLI:

```
~$ piscobox site create
```

Follow the prompts to:

1. Enter the site name — e.g. mysite
1. Choose the PHP version (e.g. 8.3)
1. Confirm the document root path (default: /var/www/html/mysite)

After creation, the site will be available at: `http://mysite.local` (if you have created a `.local` host) <br>
or directly via the VM IP: `http://192.168.56.110/mysite/` as it is commonly used.

### Sync Local Hostnames (macOS/Linux/Windows)

To make the `.local` domains work from your host machine, add the mappings to your `/etc/hosts` file.

Piscobox automatically keeps a list of all your site domains inside:

```
vagrant/.piscobox-hosts
```

You can safely sync these entries to your host by running (on your host machine, not inside the VM):
```
~$ piscobox-sync-hosts.sh
```
This command updates your system hosts file cleanly removing old Piscobox entries and adding the new ones without duplicates.

## 🐛 Troubleshooting (Quick Guide)

**🧩 PHP not executing**  
- Check PHP-FPM sockets:
```bash
~$ ls /run/php/
```
- Verify PHP-FPM service:
```bash
~$ sudo systemctl status php8.3-fpm
```
- Ensure `proxy_fcgi` is enabled:  
```bash
~$ sudo a2enmod proxy_fcgi && sudo systemctl reload apache2
```
### 🗄️ Database connection issues

Start MariaDB:
```bash
~$ sudo systemctl status mariadb
```
Test:
```bash
# Default credentials: piscoboxuser / DevPassword123
~$ mysql -u piscoboxuser -p

# Using piscobox CLI
~$ piscobox mysql login
```

### 🔄 Files not syncing

- Reload Vagrant:
```bash
~$ vagrant reload
```

- Check folder mapping in Vagrantfile

- Fix permissions:
```bash
~$ sudo chown -R vagrant:vagrant /vagrants
```

### 🌐 Local domain not resolving

- Verify `.piscobox-hosts` entries

- Run on host:
```bash
# On PiscoBox directory
~$ ./piscobox-sync-hosts.sh
```

- (Optional) Flush DNS cache

## 🤝 Contributing

Found an issue or have a suggestion? Contributions are welcome.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License – see the LICENSE file for details.

## 🙏 Acknowledgments

* Built with ❤️ for the developer community
* Thanks to all contributors and users
* Current Version: 0.1.0
* Maintainer: Philbone
* Repository: [https://github.com/philbone/piscobox](https://github.com/philbone/piscobox)
