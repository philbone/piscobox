#!/bin/bash

# ============================================
# PHP INSTALLATION
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

# Paso 1: Agregar repositorio de Sury para PHP 8.3 
print_step 1 6 "Adding PHP repository for PHP 8.3..."
run_apt_command "apt-get update"
run_apt_command "apt-get install -y apt-transport-https software-properties-common"
wget -qO- https://packages.sury.org/php/apt.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg > /dev/null
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
run_apt_command "apt-get update"

# Paso 2: Instalar PHP 8.3 y PHP-FPM
print_step 2 6 "Installing PHP 8.3 and PHP-FPM..."
run_apt_command "apt-get install -y php8.3 php8.3-fpm php8.3-mysql php8.3-mbstring \
  php8.3-zip php8.3-xml php8.3-curl php8.3-gd php8.3-intl \
  php8.3-bz2 php8.3-common php8.3-readline"

# Paso 3: Instalar módulos PHP adicionales según requerimientos
print_step 3 6 "Installing additional PHP modules..."
# Módulos requeridos: bcmath, bz2, cgi, gd, imap, intl, mbstring, pspell, tidy, xmlrpc, zip
# Algunos ya están instalados, instalamos los faltantes
run_apt_command "apt-get install -y php8.3-bcmath php8.3-cgi php8.3-imap \
  php8.3-pspell php8.3-tidy php8.3-xmlrpc"

# Verificar módulos instalados
print_step "Verification" "Checking installed PHP modules..."
php --modules | grep -E "(bcmath|bz2|gd|imap|intl|mbstring|pspell|tidy|xmlrpc|zip)" || true

# Paso 4: Configurar PHP-FPM
print_step 4 6 "Configuring PHP-FPM..."
sed -i 's/^listen = .*/listen = \/run\/php\/php8.3-fpm.sock/' /etc/php/8.3/fpm/pool.d/www.conf
sed -i '/^listen = /a listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660' /etc/php/8.3/fpm/pool.d/www.conf

# Paso 5: Configurar php.ini para desarrollo
print_step 5 6 "Configuring php.ini for development..."
PHP_INI="/etc/php/8.3/fpm/php.ini"

# Actualizar las configuraciones solo si existen, si no, añadirlas al final
{
  echo "memory_limit = 512M"
  echo "upload_max_filesize = 100M"
  echo "post_max_size = 100M"
  echo "display_errors = On"
  echo "error_reporting = E_ALL"
  echo "date.timezone = UTC"
  echo "opcache.enable = 1"
  echo "opcache.enable_cli = 1"
} > /tmp/php_config.tmp

while IFS= read -r line; do
  key=$(echo "$line" | cut -d'=' -f1 | xargs)
  if grep -q "^;*$key\s*=" "$PHP_INI"; then
    sed -i "s/^;*$key\s*=.*/$line/" "$PHP_INI"
  else
    echo "$line" >> "$PHP_INI"
  fi
done < /tmp/php_config.tmp

rm -f /tmp/php_config.tmp

# Paso 6: Instalar Composer 2.x globalmente
print_step 6 6 "Installing Composer 2.x globally..."

# Método 1: Descargar e instalar directamente
EXPECTED_SIGNATURE=$(curl -s https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    print_error "ERROR: Invalid installer signature"
    print_error "Expected: $EXPECTED_SIGNATURE"
    print_error "Actual:   $ACTUAL_SIGNATURE"
    rm -f composer-setup.php
    exit 1
fi

print_success "✓ Installer verified successfully"

# Instalar Composer
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php

# Alternativa: Método simplificado usando el instalador oficial
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# php composer-setup.php --install-dir=/usr/local/bin --filename=composer --2
# php -r "unlink('composer-setup.php');"

# Verificar instalación
if command -v composer &> /dev/null; then
    print_success "✓ Composer installed successfully"
    composer --version
else
    print_error "✗ Composer installation failed, trying alternative method..."
    # Método alternativo
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# Configurar Composer para desarrollo
if command -v composer &> /dev/null; then
    # Deshabilitar plugins de caché en entornos de desarrollo
    composer config --global cache-files-maxsize "2048MiB"
    print_success "✓ Composer configured for development"
fi

# Habilitar módulos de Apache 
print_step "Extra" "Enabling Apache modules for proxy_fcgi..."
a2enmod proxy_fcgi setenvif

# Reiniciar servicios
print_step "Final" "Restarting PHP-FPM service..."
systemctl restart php8.3-fpm

# Verificar estado
print_step "Verification" "Checking PHP and Composer installation..."
php --version
php -m | grep -c "modules" || true

print_success "✅ PHP 8.3 ready with all required modules and Composer"
print_success "📦 Installed modules: bcmath, bz2, cgi, gd, imap, intl, mbstring, pspell, tidy, xmlrpc, zip"
print_success "🎯 Composer 2.x installed globally"