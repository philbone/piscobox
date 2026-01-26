#!/bin/bash
#
# ============================================
# REDIS INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

REDIS_VERSION_REQUIRED="7.2"
REDIS_CONF="/etc/redis/redis.conf"

# Initialize
init_timer
setup_error_handling

# Display header
print_header "REDIS ${REDIS_VERSION_REQUIRED}+ INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

# 1. Dependencias
print_step 1 6 "→ Installing dependencies..."
run_apt_command "apt-get update -y"
run_apt_command "apt-get install -y curl gnupg lsb-release"

# 2. Redis official repository
print_step 2 6 "→ Adding Redis official APT repository..."
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/redis.list

run_apt_command "apt-get update -y"

# 3. Install Redis
print_step 3 6 "→ Installing Redis server..."
run_apt_command "apt-get install -y redis"

# 4. Basic configuration (Pisco Box style)
print_step 4 6 "→ Configuring Redis..."

sed -i 's/^bind .*/bind 127.0.0.1 ::1/' $REDIS_CONF
sed -i 's/^protected-mode .*/protected-mode yes/' $REDIS_CONF
sed -i 's/^# maxmemory <bytes>/maxmemory 256mb/' $REDIS_CONF
sed -i 's/^# maxmemory-policy .*/maxmemory-policy allkeys-lru/' $REDIS_CONF
sed -i 's/^supervised .*/supervised systemd/' $REDIS_CONF

# 5. Enable & start service
print_step 5 6 "→ Enabling Redis service..."
systemctl enable redis-server
systemctl restart redis-server

# 6. Verification
print_step 6 6 "→ Verifying installation..."
REDIS_VERSION=$(redis-server --version | awk '{print $3}' | cut -d= -f2)

print_success "✔ Redis installed: ${REDIS_VERSION}"
print_success "✔ Redis status:"
systemctl --no-pager status redis-server | grep Active

print_success "────────────────────────────────────────────"
print_success " Redis ready ✔"
print_success "────────────────────────────────────────────"
