#!/bin/bash

# =========================================="
#  REDIS COMMANDER INSTALLATION
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

print_step 1 6 "→ Installing Redis Commander..."

# --------------------------------------------------
# 1. Install NodeJS 18 LTS (NodeSource)
# --------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
    print_step 2 6 "→ Installing NodeJS 18 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    run_apt_command "apt-get install -y nodejs"
else
    print_success "NodeJS already installed"
fi

# --------------------------------------------------
# 2. Install Redis Commander
# --------------------------------------------------
if ! command -v redis-commander >/dev/null 2>&1; then
    print_step 3 6 "→ Installing Redis Commander..."
    npm install -g redis-commander
else
    print_success "Redis Commander already installed"
fi

# --------------------------------------------------
# 3. Create systemd service (with url prefix)
# --------------------------------------------------
SERVICE_FILE="/etc/systemd/system/redis-commander.service"

if [ ! -f "$SERVICE_FILE" ]; then
    print_step 4 6 "→ Creating Redis Commander systemd service..."

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Redis Commander
After=network.target redis-server.service

[Service]
Type=simple
ExecStart=/usr/bin/env redis-commander --bind 127.0.0.1 --port 8081 --url-prefix /redis
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
# 4. Apache reverse proxy configuration
# --------------------------------------------------
APACHE_CONF="/etc/apache2/conf-available/redis-commander.conf"

if [ ! -f "$APACHE_CONF" ]; then
    print_step 5 6 "→ Configuring Apache reverse proxy for Redis Commander..."

cat <<EOF > "$APACHE_CONF"
# Redis Commander reverse proxy

ProxyPreserveHost On

ProxyPass        /redis http://127.0.0.1:8081/redis
ProxyPassReverse /redis http://127.0.0.1:8081/redis

RequestHeader set X-Forwarded-Proto "http"
RequestHeader set X-Forwarded-Port "8080"

<Location /redis>
    Require all granted
</Location>
EOF

    a2enmod proxy proxy_http headers
    a2enconf redis-commander
    systemctl reload apache2
else
    print_success "Apache reverse proxy already configured"
fi

# --------------------------------------------------
# 5. Restart Redis Commander service
# --------------------------------------------------
print_step 6 6 "→ Restart Redis Commander service..."
systemctl restart redis-commander

print_success "Redis Commander installed and available at /redis"
