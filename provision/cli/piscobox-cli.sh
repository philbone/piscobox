#!/usr/bin/env bash

# ============================================================
#  Piscobox CLI Utility
# ============================================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

COMMAND=$1
shift || true

SITES_AVAILABLE="/etc/apache2/sites-available"
MULTIPHP_CONF="/etc/apache2/conf-enabled/piscobox-multiphp-aliases.conf"
HOSTS_FILE="/vagrant/.piscobox-hosts"

# ============================================================
#  Function: show_help
# ============================================================
show_help() {
  cat <<EOF
Piscobox CLI Utility
Usage:
  piscobox [command] [options]

Available commands:
  site create           Create a new VirtualHost and PHP site
  hosts-sync            Display instructions to sync /etc/hosts on your host
  help                  Show this help message
EOF
}

# ============================================================
#  Function: site_create
# ============================================================
site_create() {
  echo ""
  echo "=========================================="
  echo "      SITE CREATION ASSISTANT"
  echo "=========================================="

  read -rp "Enter site name (e.g. mysite): " SITE_NAME
  read -rp "Enter PHP version [8.3]: " PHP_VER
  PHP_VER=${PHP_VER:-8.3}
  read -rp "Enter document root [/var/www/${SITE_NAME}/public]: " DOC_ROOT
  DOC_ROOT=${DOC_ROOT:-/var/www/${SITE_NAME}/public}

  print_step 1 4 "Creating document root......"
  if [[ ! -d "$DOC_ROOT" ]]; then
    sudo mkdir -p "$DOC_ROOT"
    sudo chown -R vagrant:vagrant "$(dirname "$DOC_ROOT")"
    print_success "✓ ✓ Document root created at $DOC_ROOT"
  else
    print_success "✓ ✓ Document root already exists at $DOC_ROOT"
  fi

  print_step 2 4 "Creating VirtualHost......"
  CONF_PATH="${SITES_AVAILABLE}/${SITE_NAME}.conf"

  sudo tee "$CONF_PATH" >/dev/null <<EOF
<VirtualHost *:80>
    ServerName ${SITE_NAME}.local
    DocumentRoot ${DOC_ROOT}

    <Directory ${DOC_ROOT}>
        Options Indexes FollowSymLinks
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

  print_success "✓ ✓ VirtualHost created at $CONF_PATH"

  print_step 3 4 "Enabling site and reloading Apache......"
  sudo a2ensite "${SITE_NAME}.conf" >/dev/null
  sudo systemctl reload apache2
  print_success "✓ ✓ Site ${SITE_NAME}.local enabled"

  print_step 4 4 "Creating sample index.php..."
  if [[ ! -f "${DOC_ROOT}/index.php" ]]; then
    echo "<?php phpinfo(); ?>" | sudo tee "${DOC_ROOT}/index.php" >/dev/null
    sudo chown www-data:www-data "${DOC_ROOT}/index.php"
    print_success "✓ Sample index.php created"
  fi

  # Register for subdirectory (IP) access
  sudo tee -a "$MULTIPHP_CONF" >/dev/null <<EOF

# Auto-generated for ${SITE_NAME}
<Directory ${DOC_ROOT}>
    <FilesMatch "\\.php$">
        SetHandler "proxy:unix:/run/php/php${PHP_VER}-fpm.sock|fcgi://localhost/"
    </FilesMatch>
</Directory>
EOF

  # Add to hosts mapping file
  echo "192.168.56.110   ${SITE_NAME}.local" | sudo tee -a "$HOSTS_FILE" >/dev/null

  sudo systemctl reload apache2

  echo ""
  print_success "✓ Site created successfully!"
  echo ""
  echo "You can access your site at:"
  echo "  → http://${SITE_NAME}.local"
  echo "  → or http://192.168.56.110/${SITE_NAME}/"
  echo ""
  echo "To sync your host's /etc/hosts, run:"
  echo "  piscobox hosts-sync"
  echo ""
}

# ============================================================
#  Function: hosts_sync
# ============================================================
hosts_sync() {
  echo ""
  echo "=========================================="
  echo "     HOSTS SYNC UTILITY"
  echo "=========================================="
  echo ""

  if [[ ! -f "$HOSTS_FILE" ]]; then
    print_error "No .piscobox-hosts file found in /vagrant"
    echo ""
    echo "Create a site first using:"
    echo "  piscobox site create"
    return
  fi

  echo "Run this command on your host machine to sync:"
  echo ""
  echo "  cat .piscobox-hosts | sudo tee -a /etc/hosts"
  echo ""
  echo "Current entries:"
  echo "------------------------------------------"
  cat "$HOSTS_FILE"
  echo "------------------------------------------"
  echo ""
}

# ============================================================
#  Command dispatcher
# ============================================================
case "$COMMAND" in
  site)
    SUBCMD=$1
    case "$SUBCMD" in
      create) site_create ;;
      *) show_help ;;
    esac
    ;;
  hosts-sync)
    hosts_sync
    ;;
  help|--help|-h|"")
    show_help
    ;;
  *)
    print_error "Unknown command: $COMMAND"
    show_help
    ;;
esac
