#!/bin/bash
#
# ============================================
# BEANSTALK CONSOLE (ptrofimov)
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

APP_NAME="beanstalk-console"
APP_DIR="/opt/${APP_NAME}"
APP_PUBLIC_DIR="${APP_DIR}/public"
APP_REPO="https://github.com/ptrofimov/beanstalk_console.git"
APACHE_CONF="/etc/apache2/conf-available/${APP_NAME}.conf"

print_header "INSTALLING BEANSTALK CONSOLE"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------------
# Dependencies
# --------------------------------------------------
print_step 1 4 "→ Installing dependencies..."
run_apt_command "apt-get update"
run_apt_command "apt-get install -y git php-cli php-json php-mbstring"

# --------------------------------------------------
# Ensure /opt permissions (Apache traversal)
# --------------------------------------------------
print_step 2 4 "Ensuring /opt permissions..."
chmod 755 /opt

# --------------------------------------------------
# Install application
# --------------------------------------------------
if [ ! -d "$APP_DIR" ]; then
    echo "==> Cloning Beanstalk Console into ${APP_DIR}"
    git clone --depth=1 "$APP_REPO" "$APP_DIR"
else
    print_warning "Beanstalk Console already installed..."
fi

# --------------------------------------------------
# Permissions
# --------------------------------------------------
print_step 3 4 "Setting permissions..."
chown -R www-data:www-data "$APP_DIR"
chmod 755 "$APP_DIR"
chmod 755 "$APP_PUBLIC_DIR"

# --------------------------------------------------
# Apache configuration
# --------------------------------------------------
if [ ! -f "$APACHE_CONF" ]; then
    print_step 4 4 "Creating Apache config..."

    cat > "$APACHE_CONF" <<EOF
Alias /beanstalk ${APP_PUBLIC_DIR}

<Directory ${APP_PUBLIC_DIR}>
    Options FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
EOF

    a2enconf "$APP_NAME"
else
    print_warning "Apache config already exists!"
fi

# --------------------------------------------------
# Reload Apache
# --------------------------------------------------
print_step 4 4 "Reloading Apache..."
systemctl reload apache2

print_success "Beanstalk Console available at http://localhost:8080/beanstalk"
