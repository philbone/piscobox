#!/bin/bash

# ============================================
# PHP INSTALLATION (multi-version, PHP-FPM)
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "PHP INSTALLATION"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Paso 1: Agregar repositorio de Sury para PHP
print_step 1 7 "Adding PHP repository..."
run_apt_command "apt-get update"
run_apt_command "apt-get install -y apt-transport-https software-properties-common ca-certificates lsb-release curl"
wget -qO- https://packages.sury.org/php/apt.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg > /dev/null
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
run_apt_command "apt-get update"
print_success "Repository added successfully"
echo ""

# Paso 2: Instalar todas las versiones de PHP con PHP-FPM
print_step 2 7 "Installing PHP versions and FPM services..."
PHP_VERSIONS=("8.4" "8.3" "8.0" "7.4" "7.0" "5.6")
PHP_MODULES="mysql mbstring zip xml curl gd intl bz2 bcmath soap readline cli fpm"

for ver in "${PHP_VERSIONS[@]}"; do
    echo "→ Installing PHP $ver..."
    PKG_LIST=""
    for mod in $PHP_MODULES; do
        PKG_LIST="$PKG_LIST php${ver}-${mod}"
    done
    run_apt_command "apt-get install -y $PKG_LIST"
    systemctl enable "php${ver}-fpm"
    systemctl restart "php${ver}-fpm"
done

print_success "All PHP versions installed successfully"
echo ""

# Paso 3: Configurar FPM sockets y permisos
print_step 3 7 "Configuring PHP-FPM sockets and permissions..."
for ver in "${PHP_VERSIONS[@]}"; do
    POOL_FILE="/etc/php/${ver}/fpm/pool.d/www.conf"
    if [ -f "$POOL_FILE" ]; then
        sed -i "s|^listen = .*|listen = /run/php/php${ver}-fpm.sock|" "$POOL_FILE"
        sed -i "/^listen.owner/s|=.*|= www-data|" "$POOL_FILE"
        sed -i "/^listen.group/s|=.*|= www-data|" "$POOL_FILE"
        sed -i "/^listen.mode/s|=.*|= 0660|" "$POOL_FILE"
        systemctl restart "php${ver}-fpm"
    fi
done
print_success "PHP-FPM sockets configured"
echo ""

# Paso 4: Configurar PHP.ini base para desarrollo
print_step 4 7 "Configuring PHP.ini for development..."
for ver in "${PHP_VERSIONS[@]}"; do
    PHP_INI="/etc/php/${ver}/fpm/php.ini"
    if [ -f "$PHP_INI" ]; then
        sed -i "s/^memory_limit = .*/memory_limit = 512M/" "$PHP_INI"
        sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 100M/" "$PHP_INI"
        sed -i "s/^post_max_size = .*/post_max_size = 100M/" "$PHP_INI"
        sed -i "s/^display_errors = .*/display_errors = On/" "$PHP_INI"
        sed -i "s/^error_reporting = .*/error_reporting = E_ALL/" "$PHP_INI"
        sed -i "s|^;*date.timezone =.*|date.timezone = UTC|" "$PHP_INI"
    fi
done
print_success "Development configuration applied to all PHP versions"
echo ""

# Paso 5: Establecer PHP 8.3 como CLI por defecto
print_step 5 7 "Setting PHP 8.3 as system default..."
update-alternatives --set php /usr/bin/php8.3
print_success "PHP 8.3 set as default CLI version"
echo ""

# Paso 6: Instalar Composer 2.x globalmente
print_step 6 7 "Installing Composer..."
EXPECTED_SIGNATURE=$(curl -s https://composer.github.io/installer.sig)
php8.3 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php8.3 -r "echo hash_file('SHA384', 'composer-setup.php');")
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    print_error "ERROR: Invalid Composer signature"
    exit 1
fi
php8.3 composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet
rm -f composer-setup.php
print_success "Composer installed successfully"
echo ""

# Paso 7: Verificar servicios
print_step 7 7 "Verification of PHP-FPM services..."
for ver in "${PHP_VERSIONS[@]}"; do
    systemctl is-active --quiet "php${ver}-fpm" && print_success "PHP ${ver}-FPM active" || print_error "PHP ${ver}-FPM inactive"
done
php --version | head -n 1
composer --version
print_success "✅ Multi-PHP environment ready"
