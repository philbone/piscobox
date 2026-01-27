#!/bin/bash

# =========================================="
#  REDIS INSTALLATION
# =========================================="

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "REDIS INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

print_step 1 5 "→ Installing Redis Commander..."

# --------------------------------------------------
# 1. Install NodeJS 18 LTS (NodeSource)
# --------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
    print_step 2 5 "→ Installing NodeJS 18 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    run_apt_command "apt-get install -y nodejs"
else
    print_success "NodeJS already installed"
fi

# --------------------------------------------------
# 2. Install Redis Commander
# --------------------------------------------------
if ! command -v redis-commander >/dev/null 2>&1; then
    print_step 3 5 "→ Installing Redis Commander..."
    npm install -g redis-commander
else
    print_success "Redis Commander already installed"
fi

# --------------------------------------------------
# 3. Create systemd service
# --------------------------------------------------
SERVICE_FILE="/etc/systemd/system/redis-commander.service"

if [ ! -f "$SERVICE_FILE" ]; then
    print_step 4 5 "→ Creating Redis Commander systemd service..."

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Redis Commander
After=network.target redis-server.service

[Service]
Type=simple
ExecStart=/usr/bin/redis-commander --bind 127.0.0.1 --port 8081
Restart=always
User=root
Environment=REDIS_HOSTS=local:127.0.0.1:6379

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable redis-commander
else
    print_success "systemd service already exists"
fi

# --------------------------------------------------
# 4. Start service
# --------------------------------------------------
print_step 5 5 "→ Restart Redis service..."
systemctl restart redis-commander

print_success "Redis Commander installed and running"
