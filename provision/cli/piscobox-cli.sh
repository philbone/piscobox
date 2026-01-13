#!/usr/bin/env bash
# Piscobox CLI — simplified management tool for local server environment
# Author: philbone
# Version: 1.4.0

set -euo pipefail

UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

CLI_NAME="Piscobox CLI"
CLI_VERSION="1.4.0"

show_help() {
  cat <<EOF
$CLI_NAME v$CLI_VERSION

Usage: piscobox <command>

Available commands:
  help                  Show this help message
  status                Show system service status
  restart               Restart web and database services
  logs                  Display last lines of Apache error log
  info                  Show PHP and Apache info
  site create           Create and configure a new Apache VirtualHost (multi-PHP)
EOF
}

show_status() {
  print_header "SYSTEM STATUS"
  echo ""
  systemctl --no-pager --plain --type=service | grep -E "apache2|php|mariadb|mysql" || true
  echo ""
}

restart_services() {
  print_header "RESTARTING SERVICES"
  echo ""
  print_step 1 3 "Restarting Apache..."
  systemctl restart apache2
  print_success "✓ Apache restarted successfully"
  print_step 2 3 "Restarting PHP-FPM..."
  systemctl restart php*-fpm || true
  print_success "✓ PHP-FPM services restarted"
  print_step 3 3 "Restarting MariaDB..."
  systemctl restart mariadb
  print_success "✓ MariaDB restarted"
  echo ""
}

show_logs() {
  print_header "APACHE ERROR LOGS"
  echo ""
  tail -n 40 /var/log/apache2/error.log || echo "No logs found."
  echo ""
}

show_info() {
  print_header "SYSTEM INFORMATION"
  echo ""
  echo "Hostname: $(hostname)"
  echo "Apache: $(apache2 -v | head -n1)"
  echo "PHP: $(php -v | head -n1)"
  echo "MariaDB: $(mariadb --version 2>/dev/null || echo 'not installed')"
  echo ""
}

# ------------------------------------------------------------------
# NEW COMMAND: site create
# ------------------------------------------------------------------

site_create() {
  print_header "SITE CREATION ASSISTANT"

  read -rp "Enter site name (e.g. mysite): " SITE_NAME
  [[ -z "$SITE_NAME" ]] && { print_error "Site name cannot be empty."; exit 1; }

  read -rp "Enter PHP version [8.3]: " PHP_VER
  PHP_VER=${PHP_VER:-8.3}

  read -rp "Enter document root [/var/www/${SITE_NAME}/public]: " DOC_ROOT
  DOC_ROOT=${DOC_ROOT:-/var/www/${SITE_NAME}/public}

  local VHOST_FILE="/etc/apache2/sites-available/${SITE_NAME}.conf"

  if [[ ! -S /run/php/php${PHP_VER}-fpm.sock ]]; then
    print_error "PHP-FPM socket for version ${PHP_VER} not found: /run/php/php${PHP_VER}-fpm.sock"
    echo "Available sockets:"
    ls -1 /run/php/*.sock 2>/dev/null || true
    exit 1
  fi

  print_step 1 4 "Creating document root..."
  sudo mkdir -p "$DOC_ROOT"
  sudo chown -R www-data:www-data "$DOC_ROOT"
  sudo chmod -R 755 "$DOC_ROOT"
  print_success "✓ Document root created at $DOC_ROOT"

  print_step 2 4 "Creating VirtualHost..."
  sudo tee "$VHOST_FILE" >/dev/null <<EOF
<VirtualHost *:80>
    ServerName ${SITE_NAME}.local
    DocumentRoot ${DOC_ROOT}

    <Directory ${DOC_ROOT}>
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch "\\.php$">
        SetHandler "proxy:unix:/run/php/php${PHP_VER}-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}-access.log combined
</VirtualHost>
EOF

  print_success "✓ VirtualHost created at $VHOST_FILE"

  print_step 3 4 "Enabling site and reloading Apache..."
  sudo a2ensite "${SITE_NAME}.conf" >/dev/null
  sudo systemctl reload apache2
  print_success "✓ Site ${SITE_NAME}.local enabled"

  print_step 4 4 "Creating sample index.php..."
if [[ ! -f "${DOC_ROOT}/index.php" ]]; then
  echo "<?php phpinfo(); ?>" | sudo tee "${DOC_ROOT}/index.php" >/dev/null
  sudo chown www-data:www-data "${DOC_ROOT}/index.php"
  print_success "✓ Sample index.php created"
fi

  echo ""
  print_success "🎉 Site '${SITE_NAME}' successfully created with PHP ${PHP_VER}"
  print_success "Access it via http://${SITE_NAME}.local/"
  echo ""
}

# ------------------------------------------------------------------
# COMMAND DISPATCHER
# ------------------------------------------------------------------

case "${1:-}" in
  help|--help|-h)
    show_help
    ;;
  status)
    show_status
    ;;
  restart)
    restart_services
    ;;
  logs)
    show_logs
    ;;
  info)
    show_info
    ;;
  site)
    case "${2:-}" in
      create)
        site_create
        ;;
      *)
        print_error "Usage: piscobox site create"
        ;;
    esac
    ;;
  *)
    show_help
    ;;
esac
