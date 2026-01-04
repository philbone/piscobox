# PiscoBox 🥂

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.2+-blue.svg)](https://www.vagrantup.com)
[![Debian 12](https://img.shields.io/badge/Debian-12-C70E37.svg)](https://www.debian.org/releases/bookworm/)
[![Apache 2.4](https://img.shields.io/badge/Apache-2.4-A64D79.svg)](https://httpd.apache.org/docs/2.4/new_features_2_4.html)
[![PHP 8.3](https://img.shields.io/badge/PHP-8.3-8892BF.svg)](https://www.php.net/releases/8_3.php)
[![MariaDB](https://img.shields.io/badge/MariaDB-latest-A26D37.svg)](https://mariadb.com/docs/release-notes)
[![Composer 2.x](https://img.shields.io/badge/Composer-2.x-89552D.svg)](https://getcomposer.org)

**A modern LAMP stack for web developers based on Debian Bookworm**

PiscoBox is a ready-to-use Vagrant box built on Debian, providing a complete LAMP development environment with Apache, PHP 8.3, MariaDB, and essential tools for modern web development.

## ✨ Features

- **Operating System**: Debian Bookworm 64-bit
- **Web Server**: Apache 2.4 with PHP-FPM integration
- **PHP**: Version 8.3 with essential extensions
- **Database**: MariaDB Server & Client
- **Package Manager**: Composer 2.x for PHP dependencies
- **Development Tools**: Git, Vim, Curl, Wget, and more
- **Time Zone**: UTC with UTF-8 locale configuration
- **Synchronized Directories**: Easy file sharing between host and VM

## 🚀 Quick Start

### Prerequisites
- [Vagrant](https://www.vagrantup.com/downloads) (2.2+)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads), Parallels, or VMware

### Installation
```bash
git clone https://github.com/philbone/piscobox.git
cd piscobox
vagrant up
```

### Access
Once running, you can access your environment:

**Web Access:**
- Main URL: http://localhost:8080
- With hostname: http://piscobox.test (requires hosts configuration)

### SSH Access:
```bash
vagrant ssh
```

## 📁 Project Structure
```bash
pisco-box/
├── doc/            # Documentation and collaboration
├── extra_data/     # Extra data, backups (not web accessible)
├── provision/      # Provisioning scripts
├── public_html/    # Document root (synchronized with /var/www/html)
├── utils/          # Workflow templates and utilities
├── LICENSE
├── README.md
└── Vagrantfile
```

## 🗄️ Database Configuration
### Credentials:
- User: `piscoboxuser`
- Password: `DevPassword123`
- Host: `localhost`
- Database: `piscoboxdb`

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
- Version: 8.3 with PHP-FPM
- Extensions: bcmath, bz2, cgi, gd, imap, intl, mbstring, pspell, tidy, xmlrpc, zip
- Memory Limit: 512MB
- Upload Limit: 100MB
- Development Settings: Display errors enabled, E_ALL reporting

### Apache Modules
Enabled modules include:
- proxy_fcgi (for PHP-FPM integration)
- setenvif
- rewrite
- headers
- expires
- include

### Useful Commands
Service Management:
```bash
# Restart Apache
sudo systemctl restart apache2

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# View Apache logs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/piscobox-error.log
```

### File Operations
```bash
# Check synchronized directories
ls -la /var/www/html/

# View PHP information
curl http://localhost:8080/phpinfo.php
```

## 🔧 Customization

### Configure Local Hostname
To use http://piscobox.test instead of `localhost:8080`:

**On macOS/Linux:**
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1 piscobox.test
```

**On Windows:**
```text
# Open C:\Windows\System32\drivers\etc\hosts as Administrator
# Add: 127.0.0.1 piscobox.test
```

### Modify PHP Settings
Edit `/etc/php/8.3/fpm/php.ini` and restart PHP-FPM:
```bash
sudo nano /etc/php/8.3/fpm/php.ini
sudo systemctl restart php8.3-fpm
```

## 🐛 Troubleshooting
**PHP not executing, shows as plain text:**
- Verify Apache PHP-FPM configuration is present
- Check that PHP-FPM service is running
- Ensure `proxy_fcgi` module is enabled

**Cannot connect to database:**
- Verify MariaDB service is running
- Check credentials match those above
- Ensure you're connecting to localhost

**Files not syncing:**
- Restart Vagrant: vagrant reload
- Check Vagrantfile synced_folder configuration
- Verify file permissions

## 🤝 Contributing
Found an issue or have a suggestion? We welcome contributions!
1. Fork the repository
1. Create a feature branch (git checkout -b feature/AmazingFeature)
1. Commit your changes (git commit -m 'Add some AmazingFeature')
1. Push to the branch (git push origin feature/AmazingFeature)
1. Open a Pull Request

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

.

## 🙏 Acknowledgments
- Built with ❤️ for the developer community
- Thanks to all contributors and users
- Current Version: 0.1.0
- Maintainer: Philbone
- Repository: https://github.com/philbone/piscobox