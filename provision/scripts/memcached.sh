#!/bin/bash

# ============================================
# MEMCACHED
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "CACHE MEMCACHED"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------------
# Step 1: Install Memcached
# --------------------------------------------------
print_step 1 4 "Installing Memcached..."
run_apt_command "apt-get install -y memcached"
if [ $? -eq 0 ]; then
    print_success "Memcached package installed"
else
    print_error "Error installing Memcached"
fi
echo ""

# --------------------------------------------------
# Step 2: Configure Memcached
# --------------------------------------------------
print_step 2 4 "Configuring Memcached..."
MEMCACHED_CONF="/etc/memcached.conf"

if [ -f "$MEMCACHED_CONF" ]; then
    sed -i 's/^-l .*/-l 127.0.0.1/' "$MEMCACHED_CONF"
    sed -i 's/^-p .*/-p 11211/' "$MEMCACHED_CONF"
    sed -i 's/^-m .*/-m 128/' "$MEMCACHED_CONF"

    print_success "Memcached configured for local development"
else
    print_error "Memcached configuration file not found"
fi
echo ""

# --------------------------------------------------
# Step 3: Enable and start service
# --------------------------------------------------
print_step 3 4 "Starting Memcached service..."
systemctl enable memcached
systemctl restart memcached

if systemctl is-active --quiet memcached; then
    print_success "Memcached service is running"
else
    print_error "Memcached service failed to start"
fi
echo ""

# --------------------------------------------------
# Step 4: Install PHP Memcached extensions
# --------------------------------------------------
print_step 4 4 "Installing PHP Memcached extension..."

PHP_VERSIONS=$(ls /etc/php 2>/dev/null || true)

for PHP_VER in $PHP_VERSIONS; do
    if apt-cache show php${PHP_VER}-memcached >/dev/null 2>&1; then
        echo "  → Installing php${PHP_VER}-memcached"
        run_apt_command "apt-get install -y php${PHP_VER}-memcached"
        phpenmod -v ${PHP_VER} memcached >/dev/null 2>&1 || true
        systemctl restart php${PHP_VER}-fpm >/dev/null 2>&1 || true
    else
        print_warning "php${PHP_VER}-memcached not available"
    fi
done

print_success "PHP Memcached extension processed"
echo ""

# --------------------------------------------------
# Verification
# --------------------------------------------------
memcached -V >/dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Memcached ready and configured"
else
    print_error "Error verifying Memcached installation"
fi
echo ""

# --------------------------------------------------
# Print connection info
# --------------------------------------------------
print_header "Memcached Connection Info"
echo "host     : 127.0.0.1"
echo "port     : 11211"
echo "memory   : 128 MB"
echo "auth     : disabled (development only)"
echo ""
echo -e "${NC}Test via CLI:${SUCCESS_COLOR} echo stats | nc 127.0.0.1 11211${NC}"
echo ""
echo -e "${NC}PHP example:${SUCCESS_COLOR}"
echo "\$memcached = new Memcached();"
echo "\$memcached->addServer('127.0.0.1', 11211);"
echo "\$memcached->set('ping', 'pong');"
echo "echo \$memcached->get('ping');${NC}"
echo ""
