#!/bin/bash
# ============================================
# XDEBUG INSTALLATION (Multi-PHP aware)
# Supports both Xdebug 2.x (PHP ≤7.1) and 3.x+
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "XDEBUG INSTALLATION"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------
# Step 1: Detect installed PHP versions
# --------------------------------------------
print_step 1 5 "Detecting installed PHP versions..."
PHP_BASE_DIR="/etc/php"
PHP_VERSIONS=()
for dir in "$PHP_BASE_DIR"/*; do
    [ -d "$dir" ] && PHP_VERSIONS+=("$(basename "$dir")")
done

if [ ${#PHP_VERSIONS[@]} -eq 0 ]; then
    print_error "No PHP versions detected under /etc/php/"
    exit 1
fi

echo "→ Found PHP versions: ${PHP_VERSIONS[*]}"
echo ""

# --------------------------------------------
# Step 2: Install Xdebug for each PHP version
# --------------------------------------------
print_step 2 5 "Installing Xdebug for each PHP version..."

for ver in "${PHP_VERSIONS[@]}"; do
    echo "→ Installing for PHP $ver..."
    if apt-cache show "php${ver}-xdebug" >/dev/null 2>&1; then
        sudo apt-get install -y "php${ver}-xdebug"
    else
        echo "⚠️  Package php${ver}-xdebug not found, installing via PECL..."
        sudo apt-get install -y php-pear "php${ver}-dev" build-essential
        yes | sudo pecl install xdebug
    fi
done
echo "✅ Installation phase completed."
echo ""

# --------------------------------------------
# Step 3: Configure xdebug.ini for each PHP version
# --------------------------------------------
print_step 3 5 "Creating and enabling xdebug.ini for each PHP version..."

for ver in "${PHP_VERSIONS[@]}"; do
    CONF_DIR="/etc/php/${ver}/mods-available"
    CONF_FILE="${CONF_DIR}/xdebug.ini"
    echo "→ Configuring PHP $ver"

    sudo mkdir -p "$CONF_DIR"

    EXT_DIR=$(php${ver} -i 2>/dev/null | grep ^extension_dir | awk '{print $3}')
    XDEBUG_PATH="${EXT_DIR}/xdebug.so"

    # Determine major.minor version as float
    VER_FLOAT=$(echo "$ver" | awk -F'.' '{print $1"."$2}')

    if (( $(echo "$VER_FLOAT <= 7.1" | bc -l) )); then
        # Legacy configuration for Xdebug 2.x
        sudo tee "$CONF_FILE" > /dev/null <<EOF
zend_extension=${XDEBUG_PATH}

[xdebug]
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host=10.0.2.2
xdebug.remote_port=9000
xdebug.remote_connect_back=1
xdebug.profiler_enable=0
xdebug.profiler_output_dir=/tmp
xdebug.idekey=VAGRANT
EOF
    else
        # Modern configuration for Xdebug 3.x+
        sudo tee "$CONF_FILE" > /dev/null <<EOF
zend_extension=${XDEBUG_PATH}

[xdebug]
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.discover_client_host=true
xdebug.client_host=10.0.2.2
xdebug.client_port=9003
xdebug.log=/var/log/xdebug-${ver}.log
xdebug.log_level=7
EOF
    fi

    if command -v phpenmod >/dev/null 2>&1; then
        sudo phpenmod -v "$ver" xdebug
    fi
done
echo "✅ Configuration files created."
echo ""

# --------------------------------------------
# Step 4: Restart Apache & PHP-FPM services
# --------------------------------------------
print_step 4 5 "Restarting Apache and all PHP-FPM services..."
sudo service apache2 restart || true

if command -v systemctl >/dev/null 2>&1; then
  for SERVICE in $(systemctl list-units --type=service --all | grep -oP 'php[\d\.]+-fpm\.service'); do
    echo "→ Restarting $SERVICE"
    sudo systemctl restart "$SERVICE"
  done
fi
echo "✅ Services restarted."
echo ""

# --------------------------------------------
# Step 5: Verify Xdebug activation
# --------------------------------------------
print_step 5 5 "Verifying Xdebug installation for all PHP versions..."
SUCCESS_VERSIONS=()
LEGACY_VERSIONS=()
FAILED_VERSIONS=()

for ver in "${PHP_VERSIONS[@]}"; do
    if php${ver} -m 2>/dev/null | grep -iq xdebug; then
        # Detect if using Xdebug 2.x (no xdebug_info())
        if php${ver} -r "exit(function_exists('xdebug_info') ? 0 : 1);" 2>/dev/null; then
            echo "✓ Xdebug 3 active for PHP $ver"
            SUCCESS_VERSIONS+=("$ver")
        else
            echo "⚠ Xdebug 2.x detected for PHP $ver (no xdebug_info)"
            LEGACY_VERSIONS+=("$ver")
        fi
    else
        echo "❌ Xdebug missing for PHP $ver"
        FAILED_VERSIONS+=("$ver")
    fi
done

echo ""
print_success "Xdebug installation summary:"
[[ ${#SUCCESS_VERSIONS[@]} -gt 0 ]] && echo " ✓ Xdebug 3 active: ${SUCCESS_VERSIONS[*]}"
[[ ${#LEGACY_VERSIONS[@]} -gt 0 ]] && echo " ⚠  Xdebug 2.x (legacy): ${LEGACY_VERSIONS[*]}"
[[ ${#FAILED_VERSIONS[@]} -gt 0 ]] && echo " ❌ Missing: ${FAILED_VERSIONS[*]}"

print_success "XDEBUG INSTALLATION COMPLETED"
