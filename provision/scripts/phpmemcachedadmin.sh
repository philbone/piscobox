#!/bin/bash

# ============================================
# PHPMEMCACHEDADMIN
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

INSTALL_DIR="/usr/share/phpmemcachedadmin"
APACHE_CONF="/etc/apache2/conf-available/phpmemcachedadmin.conf"
REPO_URL="https://github.com/elijaa/phpmemcachedadmin.git"

# phpMemcachedAdmin is bound to modern PHP-FPM only (8.2+)
list_installed_php_fpm_services() {
  systemctl list-unit-files --type=service \
    | awk '/php8\.[234]-fpm.service/ {print $1}'
}

# --------------------------------------------------
# Init
# --------------------------------------------------
init_timer
setup_error_handling

print_header "MEMCACHED ADMIN PHPMEMCACHEDADMIN"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------------
# Step 1: Install dependencies
# --------------------------------------------------
print_step 1 5 "Installing dependencies..."
run_apt_command "apt-get install -y git"
print_success "Dependencies installed"
echo ""

# --------------------------------------------------
# Step 2: Download phpMemcachedAdmin
# --------------------------------------------------
print_step 2 5 "Installing phpMemcachedAdmin..."

if [ -d "$INSTALL_DIR" ]; then
  print_warning "phpMemcachedAdmin already exists, skipping download"
else
  git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" >/dev/null 2>&1
  print_success "phpMemcachedAdmin downloaded"
fi
echo ""

# --------------------------------------------------
# Step 3: Configure phpMemcachedAdmin
# --------------------------------------------------
print_step 3 5 "Configuring phpMemcachedAdmin..."

CONFIG_DIR="${INSTALL_DIR}/Config"
CONFIG_SAMPLE="${CONFIG_DIR}/Memcache.sample.php"
CONFIG_FILE="${CONFIG_DIR}/Memcache.php"

if [ -f "$CONFIG_SAMPLE" ] && [ ! -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_SAMPLE" "$CONFIG_FILE"
  print_success "Memcache.php configuration file created"
fi

sed -i "s/'host'[[:space:]]*=>.*/'host' => '127.0.0.1',/" "$CONFIG_FILE"
sed -i "s/'port'[[:space:]]*=>.*/'port' => 11211,/" "$CONFIG_FILE"

chown -R www-data:www-data "$INSTALL_DIR"
print_success "Memcached connection configured"
echo ""

# --------------------------------------------------
# Step 4: Configure Apache alias
# --------------------------------------------------
print_step 4 5 "Configuring Apache alias..."

# Start only installed PHP-FPM services (8.2–8.4)
for svc in $(list_installed_php_fpm_services); do
  systemctl start "$svc" 2>/dev/null || true
done

PHP_FPM_SOCKET=$(detect_php_fpm_socket 'php8\.[234]-fpm\.service')

if [[ -z "$PHP_FPM_SOCKET" ]]; then
  print_error "No compatible/active PHP-FPM socket found for phpMemcachedAdmin"
  exit 1
fi

print_success "Using PHP-FPM socket: ${PHP_FPM_SOCKET}"

cat <<EOF > "$APACHE_CONF"
Alias /memcached ${INSTALL_DIR}

<Directory ${INSTALL_DIR}>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

    <IfModule mod_proxy_fcgi.c>
        <FilesMatch \.php$>
            SetHandler "proxy:unix:${PHP_FPM_SOCKET}|fcgi://localhost/"
        </FilesMatch>
    </IfModule>

    Require all granted
</Directory>
EOF

a2enconf phpmemcachedadmin >/dev/null
echo ""

# --------------------------------------------------
# Step 6: Reload services
# --------------------------------------------------
print_step 5 5 "Reloading services..."

systemctl reload apache2

for svc in $(list_installed_php_fpm_services); do
  systemctl reload "$svc" 2>/dev/null || true
done

print_success "phpMemcachedAdmin installed and fully configured"
print_success "Access: http://localhost:8080/memcached"
print_success "Memcached: 127.0.0.1:11211"
print_success "PHP-FPM socket: ${PHP_FPM_SOCKET}"
echo ""
