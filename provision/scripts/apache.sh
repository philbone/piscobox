#!/bin/bash
#
# ============================================
# APACHE 2 INSTALLATION (multi-PHP support)
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "APACHE 2 INSTALLATION"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Paso 1: Instalar Apache
print_step 1 7 "Installing Apache and modules..."
run_apt_command "apt-get install -y apache2 libapache2-mod-fcgid"
a2dismod mpm_event 2>/dev/null || true
a2enmod mpm_prefork proxy_fcgi setenvif rewrite actions alias headers >/dev/null
print_success "Apache installed successfully with required modules"
echo ""

# Paso 2: Limpiar configuración previa
print_step 2 7 "Cleaning previous VirtualHosts..."
rm -f /etc/apache2/sites-enabled/*.conf
rm -f /etc/apache2/sites-available/*.conf
print_success "Previous VirtualHosts cleaned"
echo ""

# Paso 3: Crear VirtualHosts por versión de PHP
print_step 3 7 "Creating VirtualHosts for PHP versions..."
PHP_VERSIONS=("8.4" "8.3" "8.0" "7.4" "7.0" "5.6")

for ver in "${PHP_VERSIONS[@]}"; do
    SITE_DIR="/var/www/php${ver}"
    mkdir -p "$SITE_DIR"
    echo "<?php phpinfo(); ?>" > "${SITE_DIR}/index.php"

    cat > "/etc/apache2/sites-available/php${ver}.conf" <<EOF
<VirtualHost *:80>
    ServerName php${ver}.local
    DocumentRoot ${SITE_DIR}

    <Directory ${SITE_DIR}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php${ver}-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/php${ver}_error.log
    CustomLog \${APACHE_LOG_DIR}/php${ver}_access.log combined
</VirtualHost>
EOF

    a2ensite "php${ver}.conf" >/dev/null
done

print_success "VirtualHosts created for all PHP versions"
echo ""

# Paso 4: Configurar sitio por defecto (PHP 8.3)
print_step 4 7 "Creating default VirtualHost for PHP 8.3..."
mkdir -p /var/www/html
echo "<?php phpinfo(); ?>" > /var/www/html/index.php

cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerName piscobox-dev.local
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    # Optional inclusion for subdirectory (IP-based) sites
    IncludeOptional /etc/apache2/conf-enabled/piscobox-multiphp-aliases.conf

    ErrorLog ${APACHE_LOG_DIR}/piscobox-error.log
    CustomLog ${APACHE_LOG_DIR}/piscobox-access.log combined
</VirtualHost>
EOF

a2ensite 000-default.conf >/dev/null
print_success "Default VirtualHost enabled"
echo ""

# Paso 5: Crear fichero de configuración multiphp vacío (si no existe)
print_step 5 7 "Preparing multiphp alias configuration..."
MULTIPHP_CONF="/etc/apache2/conf-enabled/piscobox-multiphp-aliases.conf"
if [[ ! -f "$MULTIPHP_CONF" ]]; then
    echo "# Dynamic aliases for subdirectory PHP handling" | sudo tee "$MULTIPHP_CONF" >/dev/null
fi
print_success "MultipHP alias configuration ready"
echo ""

# Paso 6: Validar configuración
print_step 6 7 "Validating Apache configuration..."
apachectl configtest
print_success "Apache syntax OK"
echo ""

# Paso 7: Reiniciar Apache
print_step 7 7 "Restarting Apache service..."
systemctl enable apache2 >/dev/null 2>&1 || true
if ! systemctl restart apache2 >/dev/null 2>&1; then
    print_warning "⚠ Apache restart failed — possibly PHP-FPM sockets not ready yet."
    print_warning "  Retrying in 5 seconds..."
    sleep 5
    systemctl restart apache2 >/dev/null 2>&1 || print_warning "⚠ Apache could not start yet. It will retry on next provision."
else
    print_success "Apache active and running"
fi

print_success "✅ Apache configured with multi-PHP VirtualHosts and alias support"
echo ""
