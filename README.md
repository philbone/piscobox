# PiscoBox 🥂

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-yellow.svg)](https://www.gnu.org/licenses/gpl-3.0.html#license-text)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.2.+-blue.svg)](https://www.vagrantup.com)
[![Debian 12](https://img.shields.io/badge/Debian-12-C70E37.svg)](https://www.debian.org/releases/bookworm/)
[![Apache 2.4](https://img.shields.io/badge/Apache-2.4-A64D79.svg)](https://httpd.apache.org/docs/2.4/new_features_2_4.html)
[![MariaDB 12](https://img.shields.io/badge/MariaDB-12-A26D37.svg)](https://mariadb.com/docs/release-notes)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-31648C.svg)](https://www.postgresql.org/docs/release/)
[![Redis 8](https://img.shields.io/badge/Redis-8.0-FF4438.svg)](https://redis.io/docs/latest/operate/rs/release-notes/)
[![Node.js 25](https://img.shields.io/badge/Nodejs-25.2.1-417E38.svg)](https://nodejs.org/en/about/previous-releases)
[![Composer 2.9.2](https://img.shields.io/badge/Composer-2.9.2-89552D.svg)](https://getcomposer.org/changelog/2.9.2)
[![Laravel 12](https://img.shields.io/badge/Laravel-12-F43003.svg)](https://laravel.com/docs/12.x)
[![Symfony 5.16](https://img.shields.io/badge/Symfony-5.16.1-000000.svg)]([https://laravel.com/docs/12.x](https://symfony.com/doc))
[![PHP 5.6](https://img.shields.io/badge/PHP-5.6-8892BF.svg)](https://www.php.net/releases/5_6_40.php)
[![PHP 7.0](https://img.shields.io/badge/PHP-7.0-8892BF.svg)](https://www.php.net/releases/7_0_33.php)
[![PHP 7.4](https://img.shields.io/badge/PHP-7.4-8892BF.svg)](https://www.php.net/releases/7_4_33.php)
[![PHP 8.0](https://img.shields.io/badge/PHP-8.0-8892BF.svg)](https://www.php.net/releases/8_0_30.php)
[![PHP 8.4](https://img.shields.io/badge/PHP-8.4-8892BF.svg)](https://www.php.net/releases/8_4_15.php)
[![Python 2](https://img.shields.io/badge/Python-2.2-458ec8.svg)](https://docs.python.org/3/whatsnew/2.2.html)
[![Python 3](https://img.shields.io/badge/Python-3.14-458ec8.svg)](https://docs.python.org/3/whatsnew/index.html)
[![Go 1.25](https://img.shields.io/badge/Go-1.25-007D9C.svg)](https://go.dev/doc/devel/release)


**A modern, multi-PHP LAMP stack for web developers**

PiscoBox is a ready-to-use Vagrant box built on Debian 12, designed for web developers 
who need a flexible, production-like environment. It supports 5 PHP versions, 
multiple databases, and comes with all essential tools for full-stack development.

## Why PiscoBox?

- 🐘 **5 PHP versions** (5.6.4, 7.0.33, 7.4.33, 8.0.30 y 8.4.15) via Sury repository
- 🪶 **Lightweight Debian 12** base - no Ubuntu bloat
- 🛠️ **Everything included**: Apache, MariaDB, PostgreSQL, Redis, Node.js, Python, Go
- 🔄 **Easy switching** between PHP versions per project
- 🚀 **Optimized for**: Laravel, Symfony, WordPress, and legacy PHP projects
- 🔧 **Sensible defaults** with production-like configurations

## Quick Start

```bash
git clone https://github.com/philbone/piscobox.git
cd piscobox
vagrant up
``` 
