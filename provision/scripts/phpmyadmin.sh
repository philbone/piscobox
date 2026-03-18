#!/bin/bash

# ============================================
# PHPMYADMIN INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

PHPMYADMIN_VERSION="5.2.1"
PHPMYADMIN_URL="https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz"

INSTALL_DIR="/usr/share/phpmyadmin"
TMP_DIR="${INSTALL_DIR}/tmp"

PMA_USER="pma"
PMA_PASS="pmapassword"

APACHE_CONF="/etc/apache2/conf-available/phpmyadmin.conf"

# Initialize
init_timer
setup_error_handling

# Display header
print_header "PHPMYADMIN ${PHPMYADMIN_VERSION} INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------------
# Step 1: PHP dependencies
# --------------------------------------------------
print_step 1 9 "Installing PHP dependencies..."
run_apt_command "apt-get update -y"
run_apt_command "apt-get install -y php-mbstring php-zip php-gd php-json php-curl unzip wget"

# --------------------------------------------------
# Step 2: Download
# --------------------------------------------------
print_step 2 9 "Downloading phpMyAdmin..."
cd /tmp
wget -q ${PHPMYADMIN_URL}

# --------------------------------------------------
# Step 3: Extract
# --------------------------------------------------
print_step 3 9 "Extracting phpMyAdmin..."
rm -rf "${INSTALL_DIR}"
tar xzf phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
mv phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages "${INSTALL_DIR}"

# --------------------------------------------------
# Step 4: Directory permissions
# --------------------------------------------------
print_step 4 9 "Configuring directories..."
mkdir -p "${TMP_DIR}"
chown -R www-data:www-data "${INSTALL_DIR}"
chmod 700 "${TMP_DIR}"

# --------------------------------------------------
# Step 5: config.inc.php
# --------------------------------------------------
print_step 5 9 "Creating config.inc.php..."
if [ ! -f "${INSTALL_DIR}/config.inc.php" ]; then
  BLOWFISH_SECRET=$(openssl rand -base64 24)

  cat <<EOF > "${INSTALL_DIR}/config.inc.php"
<?php
\$cfg['blowfish_secret'] = '${BLOWFISH_SECRET}';

\$i = 0;
\$i++;
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;

/* phpMyAdmin configuration storage */
\$cfg['Servers'][\$i]['controluser'] = '${PMA_USER}';
\$cfg['Servers'][\$i]['controlpass'] = '${PMA_PASS}';
\$cfg['Servers'][\$i]['pmadb'] = 'phpmyadmin';

\$cfg['TempDir'] = '${TMP_DIR}';
EOF
fi

# --------------------------------------------------
# Step 6: phpMyAdmin configuration storage (pmadb)
# --------------------------------------------------
print_step 6 9 "Configuring phpMyAdmin storage database..."

mysql <<EOF
CREATE USER IF NOT EXISTS '${PMA_USER}'@'localhost'
  IDENTIFIED BY '${PMA_PASS}';
FLUSH PRIVILEGES;
EOF

sed \
  -e "s/^-- GRANT /GRANT /" \
  -e "s/^--    'pma'@localhost;/'pma'@localhost;/" \
  "${INSTALL_DIR}/sql/create_tables.sql" > /tmp/phpmyadmin_create_tables.sql
mysql < /tmp/phpmyadmin_create_tables.sql

# --------------------------------------------------
# Step 7: Apache Alias + PHP-FPM autodetect
# --------------------------------------------------
print_step 7 9 "Configuring Apache alias..."

PHP_FPM_SOCKET=$(detect_php_fpm_socket)

if [[ -z "$PHP_FPM_SOCKET" ]]; then
  print_error "No active PHP-FPM socket found for phpMyAdmin"
  exit 1
fi

print_success "Using PHP-FPM socket: ${PHP_FPM_SOCKET}"

cat <<EOF > "${APACHE_CONF}"
Alias /phpmyadmin ${INSTALL_DIR}

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

a2enconf phpmyadmin >/dev/null

# --------------------------------------------------
# Step 8: Reload Apache
# --------------------------------------------------
print_step 8 9 "Reloading Apache..."
systemctl reload apache2

# --------------------------------------------------
# Step 9: Done
# --------------------------------------------------
print_step 9 9 "Finalizing installation..."

print_success "phpMyAdmin installed and fully configured"
print_success "Access: http://localhost:8080/phpmyadmin"
print_success "PHP-FPM socket: ${PHP_FPM_SOCKET}"
print_success "Configuration storage enabled (pmadb)"
