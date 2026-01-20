#!/usr/bin/env bash

# ============================================================
#  Piscobox CLI Utility (Multi-PHP aware)
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
APACHE_IP="192.168.56.110"

# ============================================================
#  Function: show_help
# ============================================================
show_help() {
  cat <<EOF
Piscobox CLI Utility
Usage:
  piscobox [command] [options]

Available commands:
  site create                 Create a new VirtualHost and PHP site
  site delete <site>          Delete a VirtualHost and remove its configuration
                              Flags: --doc-root <path> (override doc root), --no-reload (don't reload Apache), --force (no prompts, remove doc root)
  site set-php <site> <ver>   Change the PHP-FPM version used by a site
                              Flags: --no-reload (don't reload Apache), --force (apply despite warnings)
  hosts-sync                  Display instructions to sync /etc/hosts on your host
  install demo-php            Install the PHP demos
  uninstall demo-php          Uninstall the PHP demos
  mysql login                 Direct access to MySQL as the user "piscoboxuser"
  help                        Show this help message

Examples:
  # Interactive
  piscobox site set-php
  piscobox site delete

  # Non-interactive
  piscobox site set-php mysite 8.1
  piscobox site set-php mysite 7.4 --no-reload
  piscobox site delete mysite
  piscobox site delete mysite --doc-root /var/www/html/mysite
  piscobox site delete mysite --doc-root /var/www/html/mysite --force --no-reload
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
  [[ -z "$SITE_NAME" ]] && { print_error "Site name cannot be empty"; return 1; }

  read -rp "Enter PHP version [8.3]: " PHP_VER
  PHP_VER=${PHP_VER:-8.3}

  # Verify PHP socket exists
  PHP_SOCKET="/run/php/php${PHP_VER}-fpm.sock"
  if [[ ! -S "$PHP_SOCKET" ]]; then
    print_error "PHP ${PHP_VER} does not seem to be installed or its FPM service is not running."
    echo "Available PHP sockets:"
    ls /run/php/php*-fpm.sock 2>/dev/null || echo "No PHP-FPM sockets found!"
    return 1
  fi

  read -rp "Enter document root [/var/www/html/${SITE_NAME}]: " DOC_ROOT
  DOC_ROOT=${DOC_ROOT:-/var/www/html/${SITE_NAME}}

  print_step 1 5 "Creating document root..."
  if [[ ! -d "$DOC_ROOT" ]]; then
    sudo mkdir -p "$DOC_ROOT"
    sudo chown -R vagrant:vagrant "$(dirname "$DOC_ROOT")"
    print_success "✓ Document root created at $DOC_ROOT"
  else
    print_success "✓ Document root already exists at $DOC_ROOT"
  fi

  print_step 2 5 "Creating VirtualHost..."
  CONF_PATH="${SITES_AVAILABLE}/${SITE_NAME}.conf"

  sudo tee "$CONF_PATH" >/dev/null <<EOF
<VirtualHost *:80>
    ServerName ${SITE_NAME}.local
    DocumentRoot ${DOC_ROOT}

    <Directory ${DOC_ROOT}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch "\\.php$">
        SetHandler "proxy:unix:${PHP_SOCKET}|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}-access.log combined
</VirtualHost>
EOF

  print_success "✓ VirtualHost created at $CONF_PATH"

  print_step 3 5 "Enabling site and reloading Apache..."
  sudo a2ensite "${SITE_NAME}.conf" >/dev/null
  sudo systemctl reload apache2
  print_success "✓ Site ${SITE_NAME}.local enabled"

  print_step 4 5 "Creating sample index.php..."
  if [[ ! -f "${DOC_ROOT}/index.php" ]]; then
    echo "<?php phpinfo(); ?>" | sudo tee "${DOC_ROOT}/index.php" >/dev/null
    sudo chown www-data:www-data "${DOC_ROOT}/index.php"
    print_success "✓ Sample index.php created"
  fi

  print_step 5 5 "Creating sample info-xdebug.php..."
  if [[ ! -f "${DOC_ROOT}/info-xdebug.php" ]]; then
    echo '<?php
// Mostrar versión y estado de Xdebug
if (function_exists("xdebug_info")) {
// Xdebug 3+
  xdebug_info();
} elseif (function_exists("xdebug_get_version")) {
// Xdebug 2.x
  echo "Xdebug version: " . xdebug_get_version() . "\n";
  echo "Xdebug loaded in PHP " . PHP_VERSION . "\n";
} else {
  echo "Xdebug is not loaded for PHP " . PHP_VERSION . "\n";
}' | sudo tee "${DOC_ROOT}/info-xdebug.php" >/dev/null            
  fi

  # Update multiphp alias config for subdirectory (IP) access
  # Remove any previous block for same DOC_ROOT
  sudo sed -i "\|<Directory ${DOC_ROOT}>|,|</Directory>|d" "$MULTIPHP_CONF"

  sudo tee -a "$MULTIPHP_CONF" >/dev/null <<EOF

# Auto-generated for ${SITE_NAME} (${PHP_VER})
<Directory ${DOC_ROOT}>
    <FilesMatch "\\.php$">
        SetHandler "proxy:unix:${PHP_SOCKET}|fcgi://localhost/"
    </FilesMatch>
</Directory>
EOF

  # Add to hosts mapping file (avoid duplicates)
  grep -q "${SITE_NAME}.local" "$HOSTS_FILE" 2>/dev/null || \
    echo "${APACHE_IP}   ${SITE_NAME}.local" | sudo tee -a "$HOSTS_FILE" >/dev/null

  sudo systemctl reload apache2

  echo ""
  print_success "✓ Site created successfully!"
  echo ""
  echo "You can access your site at:"
  echo "  → http://${SITE_NAME}.local"
  echo "  → or http://${APACHE_IP}/${SITE_NAME}/"
  echo ""
  echo "Next step: sync your host's /etc/hosts file."
  echo ""
  echo "From your host machine (not inside the VM), run:"
  echo "  ./piscobox-sync-hosts.sh"
  echo ""
}


# ============================================================
#  Function: site_delete
# ============================================================
site_delete() {
  local SITE_NAME="$1"
  shift || true

  local NO_RELOAD=false
  local FORCE=false
  local OVERRIDE_DOC_ROOT=""

  # Parse optional flags (after positional args)
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-reload) NO_RELOAD=true; shift ;;
      --force) FORCE=true; shift ;;
      --doc-root) OVERRIDE_DOC_ROOT="$2"; shift 2 ;;
      *) break ;;
    esac
  done

  # Interactive prompt for missing site name
  if [[ -z "$SITE_NAME" ]]; then
    read -rp "Enter site name (e.g. mysite): " SITE_NAME
    [[ -z "$SITE_NAME" ]] && { print_error "Site name cannot be empty"; return 1; }
  fi

  CONF_PATH="${SITES_AVAILABLE}/${SITE_NAME}.conf"
  if [[ ! -f "$CONF_PATH" ]]; then
    print_error "No VirtualHost found at $CONF_PATH"
    echo "Check available sites in ${SITES_AVAILABLE}."
    return 1
  fi

  # Determine DocumentRoot from override or try to extract from conf
  DOC_ROOT="$OVERRIDE_DOC_ROOT"
  if [[ -z "$DOC_ROOT" ]]; then
    DOC_ROOT=$(grep -m1 -E 'DocumentRoot[[:space:]]+' "$CONF_PATH" | awk '{print $2}' || true)
  fi

  echo ""
  print_header "· SITE DELETION ·"
  echo "Site: $SITE_NAME"
  echo "VirtualHost: $CONF_PATH"
  [[ -n "$DOC_ROOT" ]] && echo "DocumentRoot: $DOC_ROOT"
  echo ""

  if ! $FORCE; then
    echo -n "Are you sure you want to delete this site? This will disable the site and remove its vhost. Proceed? [y/N]: "
    read -r ans
    if [[ ! "$ans" =~ ^([yY]|[sS]|sí|si)$ ]]; then
      echo "Deletion cancelled."
      return 0
    fi
  fi

  # Backup conf
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP="${CONF_PATH}.bak-${TIMESTAMP}"
  sudo cp "$CONF_PATH" "$BACKUP" || { print_error "Failed to create backup of $CONF_PATH"; return 1; }
  print_step 1 6 "Backup created: $BACKUP"

  # Disable site
  print_step 2 6 "Disabling site ${SITE_NAME}.conf..."
  sudo a2dissite "${SITE_NAME}.conf" >/dev/null 2>&1 || true
  print_success "✓ Site disabled"

  # Remove vhost file
  print_step 3 6 "Removing VirtualHost file..."
  sudo rm -f "$CONF_PATH" || { print_error "Failed to remove $CONF_PATH"; return 1; }
  print_success "✓ VirtualHost removed"

  # Remove multiphp alias block for this DOC_ROOT or SITE_NAME
  if [[ -f "$MULTIPHP_CONF" ]]; then
    print_step 4 6 "Cleaning multiphp aliases..."
    # Try to remove block by matching the auto-generated comment or Directory block
    sudo sed -i "\|# Auto-generated for ${SITE_NAME} (|,|</Directory>|d" "$MULTIPHP_CONF" 2>/dev/null || true
    sudo sed -i "\|<Directory ${DOC_ROOT}>|,|</Directory>|d" "$MULTIPHP_CONF" 2>/dev/null || true
    print_success "✓ Multiphp aliases cleaned"
  fi

  # Remove from hosts mapping file
  if [[ -f "$HOSTS_FILE" ]]; then
    print_step 5 6 "Removing host mapping from $HOSTS_FILE..."
    sudo sed -i "/${SITE_NAME}\.local/d" "$HOSTS_FILE" 2>/dev/null || true
    print_success "✓ Host mapping removed from $HOSTS_FILE"
  fi

  # Decide whether to remove document root
  if [[ -n "$DOC_ROOT" ]]; then
    if $FORCE; then
      # Safety checks to avoid removing common system paths
      case "$DOC_ROOT" in
        "/"|"/var"|"/var/www"|"/var/www/html"|"") 
          print_warning "Refusing to remove unsafe document root: $DOC_ROOT"
          ;;
        *)
          print_step 6 6 "Removing document root: $DOC_ROOT"
          sudo rm -rf "$DOC_ROOT" || print_warning "Failed to remove $DOC_ROOT (you may need to remove files manually)"
          print_success "✓ Document root removed (if existed)"
          ;;
      esac
    else
      # Interactive prompt, default YES
      echo ""
      read -rp "Delete document root '${DOC_ROOT}'? [Y/n]: " del_ans
      del_ans=${del_ans:-Y}
      if [[ "$del_ans" =~ ^([yY]|[sS]|sí|si)$ ]]; then
        case "$DOC_ROOT" in
          "/"|"/var"|"/var/www"|"/var/www/html"|"")
            print_warning "Refusing to remove unsafe document root: $DOC_ROOT"
            ;;
          *)
            print_step 6 6 "Removing document root: $DOC_ROOT"
            sudo rm -rf "$DOC_ROOT" || print_warning "Failed to remove $DOC_ROOT (you may need to remove files manually)"
            print_success "✓ Document root removed (if existed)"
            ;;
        esac
      else
        echo "Document root preserved: $DOC_ROOT"
      fi
    fi
  fi

  # Reload apache unless requested not to
  if ! $NO_RELOAD; then
    sudo systemctl reload apache2 || { print_warning "Failed to reload apache2; please check apache configuration"; }
    echo ""
    print_success "✓ Apache reloaded"
  else
    print_warning "Apache reload skipped (--no-reload)"
  fi

  # Limpieza de backups antiguos
  cleanup_sites_available_bak

  echo ""
  print_success "Site ${SITE_NAME} deleted/unset locally."
  echo "If you use host-level /etc/hosts entries, run ./piscobox-sync-hosts.sh on your host to sync and remove the $SITE_NAME.local entry."
  echo ""
  return 0
}

# ============================================================
#  Function: site_set_php_version
#  Usage:
#   Non-interactive: piscobox site set-php <site_name> <php_version> [--doc-root <path>] [--no-reload] [--force]
#   Interactive (only for missing site/version): piscobox site set-php
# ============================================================
site_set_php_version() {
  local SITE_NAME="$1"
  local PHP_VER="$2"
  shift 2 || true

  local NO_RELOAD=false
  local FORCE=false
  local OVERRIDE_DOC_ROOT=""

  # Parse optional flags (after positional args)
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-reload) NO_RELOAD=true; shift ;;
      --force) FORCE=true; shift ;;
      --doc-root) OVERRIDE_DOC_ROOT="$2"; shift 2 ;;
      *) break ;;
    esac
  done

  # Interactive prompts only for missing site name / php version
  if [[ -z "$SITE_NAME" ]]; then
    read -rp "Enter site name (e.g. mysite): " SITE_NAME
    [[ -z "$SITE_NAME" ]] && { print_error "Site name cannot be empty"; return 1; }
  fi

  if [[ -z "$PHP_VER" ]]; then
    read -rp "Enter PHP version (e.g. 8.3): " PHP_VER
    PHP_VER=${PHP_VER:-8.3}
  fi

  local CONF_PATH="${SITES_AVAILABLE}/${SITE_NAME}.conf"
  if [[ ! -f "$CONF_PATH" ]]; then
    print_error "VirtualHost file not found: $CONF_PATH"
    return 1
  fi

  # Extract DocumentRoot from the vhost conf (used to update MULTIPHP_CONF)
  local DOC_ROOT
  DOC_ROOT=$(grep -i '^[[:space:]]*DocumentRoot' "$CONF_PATH" | head -n1 | awk '{print $2}' | tr -d '"')

  # Allow override via --doc-root
  if [[ -n "$OVERRIDE_DOC_ROOT" ]]; then
    DOC_ROOT="$OVERRIDE_DOC_ROOT"
  fi

  if [[ -z "$DOC_ROOT" ]]; then
    print_error "No DocumentRoot could be determined from $CONF_PATH."
    echo "If your VirtualHost uses includes or a non-standard layout, provide the document root with --doc-root <path>."
    return 1
  fi

  local PHP_SOCKET="/run/php/php${PHP_VER}-fpm.sock"
  if [[ ! -S "$PHP_SOCKET" ]]; then
    if systemctl is-active --quiet "php${PHP_VER}-fpm"; then
      print_warning "Socket $PHP_SOCKET not found but service php${PHP_VER}-fpm is active. Continuing."
    else
      if [[ "$FORCE" == true ]]; then
        print_warning "PHP socket $PHP_SOCKET not found and service php${PHP_VER}-fpm seems down/not installed. Continuing due to --force."
      else
        print_error "PHP ${PHP_VER} does not seem to be installed or php${PHP_VER}-fpm is not running."
        echo "Expected socket: $PHP_SOCKET"
        echo "If you want to force the change anyway, re-run with --force"
        return 1
      fi
    fi
  fi

  # Backup the vhost file
  local BACKUP="${CONF_PATH}.bak.$(date +%s)"
  sudo cp "$CONF_PATH" "$BACKUP" || { print_error "Failed to create backup of $CONF_PATH"; return 1; }
  print_step 1 3 "Backup created: $BACKUP"

  # Replace any existing php*-fpm socket in the SetHandler lines of the vhost
  sudo sed -i.bak -E "s|(proxy:unix:)/run/php/php[0-9]+\.[0-9]+-fpm.sock|\1${PHP_SOCKET}|g" "$CONF_PATH" || true
  sudo sed -i.bak -E "s|(proxy:unix:)/run/php/php[0-9]+-fpm.sock|\1${PHP_SOCKET}|g" "$CONF_PATH" || true

  # Fallback replacement if needed
  if ! grep -q "${PHP_SOCKET}" "$CONF_PATH"; then
    sudo perl -0777 -pe "s|(<FilesMatch \\\\\"\\\\.php\\\\\"\\>\\n\\s*SetHandler\\s+\\\")[^\"]*(\\\"\\s*\\/)\\s*|\\1proxy:unix:${PHP_SOCKET}|s" -i "$CONF_PATH" 2>/dev/null || true
  fi

  # Update multiphp aliases: remove prior block for DOC_ROOT then append new one
  if [[ -f "$MULTIPHP_CONF" ]]; then
    sudo sed -i "\|<Directory ${DOC_ROOT}>|,|</Directory>|d" "$MULTIPHP_CONF" || true
  else
    sudo tee "$MULTIPHP_CONF" >/dev/null <<<"# Dynamic aliases for subdirectory PHP handling"
  fi

  sudo tee -a "$MULTIPHP_CONF" >/dev/null <<EOF

# Auto-generated for ${SITE_NAME} (${PHP_VER})
<Directory ${DOC_ROOT}>
    <FilesMatch "\\.php$">
        SetHandler "proxy:unix:${PHP_SOCKET}|fcgi://localhost/"
    </FilesMatch>
</Directory>
EOF

  print_step 2 3 "Configuration updated for ${SITE_NAME} -> PHP ${PHP_VER}"

  # Reload Apache unless requested not to
  if [[ "$NO_RELOAD" == true ]]; then
    print_warning "Skipping apache reload due to --no-reload flag. Remember to reload apache2 manually."
  else
    print_step 3 3 "Reloading Apache..."
    if sudo systemctl reload apache2; then
      print_success "✓ PHP version for site ${SITE_NAME} set to ${PHP_VER} and Apache reloaded successfully."
    else
      print_error "Apache reload failed after applying changes."
      if [[ "$FORCE" == true ]]; then
        print_warning "Continuing despite reload failure due to --force. Check Apache logs for details."
      else
        print_warning "Attempting rollback from backup..."
        sudo cp "$BACKUP" "$CONF_PATH" || print_error "Rollback failed: could not restore $BACKUP to $CONF_PATH"
        sudo systemctl reload apache2 || print_warning "Rollback reload failed — please inspect Apache configuration"
        return 1
      fi
    fi
  fi

  # Limpieza de backups antiguos
  cleanup_sites_available_bak

  echo ""
  print_success "Operation complete. You can verify with a phpinfo() or curl -H \"Host: ${SITE_NAME}.local\" http://127.0.0.1/"
  return 0
}

# ============================================================
#  Function: hosts_sync
# ============================================================
hosts_sync() {
  echo ""
  echo "=========================================="
  echo "     HOSTS SYNC INSTRUCTIONS"
  echo "=========================================="
  echo ""

  if [[ ! -f "$HOSTS_FILE" ]]; then
    print_error "No .piscobox-hosts file found in /vagrant"
    echo ""
    echo "Create a site first using:"
    echo "  piscobox site create"
    return
  fi

  echo "To properly sync your host's /etc/hosts, use the new helper script:"
  echo ""
  echo "  ./piscobox-sync-hosts.sh"
  echo ""
  echo "This script will safely merge entries from .piscobox-hosts into /etc/hosts,"
  echo "avoiding duplicates and keeping your system clean."
  echo ""
  echo "Current generated entries:"
  echo "------------------------------------------"
  cat "$HOSTS_FILE"
  echo "------------------------------------------"
  echo ""
}

install_demo_php() {
  #saludar
  print_header "· PISCOBOX PHP DEMO INSTALLER ·"
  #solicitar confirmación, descomprimir demos en un directorio temporal, mover demos a public_html/piscoweb/demos/php, despedir y mostrar la salida."
  print_warning "The installation will take place in public_html/piscoweb/demos..."
  print_warning "The 'videogames' table will be created in the 'piscoboxdb' database"
  echo -n "Do you want to proceed with the installation? Y/n: "
  read rs;
  if [[ $rs == "y" || $rs == "Y" || $rs == "yes" || $rs == "YES" || $rs == "s" || $rs == "si" || $rs == "sí" || $rs == "SI" || $rs == "SÍ" ]]; then
   # instalado DEMOS PHP
   print_success "installing PHP demos...❯❯❯❯"
   rm -rf /var/tmp/demos/ 
   mkdir -p /var/tmp/demos/php

   print_step 1 3 " Unpacking PHP demo"
   unzip /vagrant/provision/files/demos/demo-php.zip -d /var/tmp/demos/php
   if [ $? -eq 0 ];then
    print_success "PHP demo unpacking to /var/tmp"
  fi

  print_step 2 3 " Creating the necessary tables..."
  mysql -u piscoboxuser -pDevPassword123 piscoboxdb < /var/tmp/demos/php/create_gamevault.sql
  if [ $? -eq 0 ];then
    print_success "Tables created"
  fi

  print_step 3 3 " Creating the destination directory and moving the files"
  sudo mkdir -p /var/www/html/piscoweb/demos/
  sudo mv /var/tmp/demos/php/*.php /var/www/html/piscoweb/demos/
  sudo mv /var/tmp/demos/php/demos.json /var/www/html/piscoweb/demos/
  if [ $? -eq 0 ];then
    print_success "demos php instalados en public_html/piscoweb/demos/ "
    rm -r /var/tmp/demos/
  fi

else
 print_error "The demos will not be installed "
fi
# mysql -u piscoboxuser -pDevPassword123 piscoboxdb < /vagrant/provision/files/create_gamevault.sql
}

# ============================================================
#  Function: uninstall_demo_php
# ============================================================
uninstall_demo_php() {
  print_header "· PISCOBOX PHP DEMO UNINSTALLER ·"   
  print_warning "The PHP files in public_html/piscoweb/demos will be ERASED"
  print_warning "The 'videogames' table will be DELETED from 'piscoboxdb' database"
  echo -n "Do you want to proceed with the delete process? Y/n: "
  read rs;
  if [[ $rs == "y" || $rs == "Y" || $rs == "yes" || $rs == "YES" || $rs == "s" || $rs == "si" || $rs == "sí" || $rs == "SI" || $rs == "SÍ" ]]; then
    print_success "Uninstall PHP demos...❯❯❯❯"

    print_step 1 3 "Deleting the database tables "
    mysql -u piscoboxuser -pDevPassword123 -D piscoboxdb -e 'DROP TABLE IF EXISTS videogames;'

    print_step 2 3 "Removing all PHP files from the demos directory "
    sudo rm -rf /var/www/html/piscoweb/demos/*.php
    sudo rm -rf /var/www/html/piscoweb/demos/demos.json

    if [ -z "$( ls -A '/var/www/html/piscoweb/demos/' )" ]; then    
     print_step 3 3 "Removing the empty demos directory "
     sudo rm -rf /var/www/html/piscoweb/demos/
   else
     echo "Not Empty"
   fi
  else
    echo "uninstall Canceled"
  fi
}

# ============================================================
#  Function: mysql login
# ============================================================
mysql_login() {
  mysql -u piscoboxuser -pDevPassword123
}

# ============================================================
#  Function: cleanup_sites_available_bak
# ============================================================
cleanup_sites_available_bak() {
    local backup_dir="/etc/apache2/sites-available"
    local keep=2  # número de backups a conservar por sitio

    # Agrupamos por nombre base del sitio (antes del .conf.bak)
    for site in $(ls "$backup_dir"/*.conf.bak* 2>/dev/null | sed -E 's|.*/([^/]+)\.conf\.bak.*|\1|' | sort -u); do
        # Listar los backups ordenados por fecha (más antiguos primero)
        backups=( $(ls -1t "$backup_dir/${site}.conf.bak"* 2>/dev/null) )
        
        # Si hay más de $keep, eliminamos los antiguos
        if [ ${#backups[@]} -gt $keep ]; then
            old_backups=( "${backups[@]:$keep}" )
            echo "🧹 Cleaning sites-available configuration of $site..."
            sudo rm -f "${old_backups[@]}"
          else
            echo "There is nothing to clean"
        fi
    done
}

# ============================================================
#  Command dispatcher
# ============================================================
case "$COMMAND" in
  site)
    SUBCMD=$1
    case "$SUBCMD" in
      create) site_create ;;
      set-php) shift; site_set_php_version "$@" ;;
      set-php-version) shift; site_set_php_version "$@" ;;
      delete) shift; site_delete "$@" ;;
      available-cleanup) cleanup_sites_available_bak ;;
      *) show_help ;;
    esac
    ;;
  hosts-sync)
    hosts_sync
    ;;
  help|--help|-h|"")
    show_help
    ;;
  install)
    SUBCMD=$1
    case "$SUBCMD" in
      demo-php) install_demo_php ;;
      *) show_help ;;
    esac
    ;;
  uninstall)
    SUBCMD=$1
    case "$SUBCMD" in
      demo-php) uninstall_demo_php ;;
      *) show_help ;;
    esac
    ;;
  mysql|mariadb)
    SUBCMD=$1
    case "$SUBCMD" in
      login) mysql_login ;;
      *) show_help ;;
    esac
    ;;
  *)
    print_error "Unknown command: $COMMAND"
    show_help
    ;;
esac
