#!/bin/bash
#
# ============================================
# SQLITE WEB INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "SQLITE WEB INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

# --------------------------------------------------
# 1. System update & dependencies
# --------------------------------------------------
print_step 1 6 "Updating system"
run_apt_command "apt-get update"

print_step 2 6 "Installing Python and SQLite"
run_apt_command "apt-get install -y python3 python3-pip sqlite3"

# --------------------------------------------------
# 2. Install sqlite-web
# --------------------------------------------------
if ! command -v sqlite_web >/dev/null 2>&1; then
    print_step 3 6 "Installing SQLite Web"
    pip3 install --break-system-packages sqlite-web
else
    print_success "SQLite Web already installed"
fi

# --------------------------------------------------
# 3. Prepare SQLite directory & database
# --------------------------------------------------
print_step 4 6 "Preparing SQLite directory and database"

SQLITE_DIR="/var/sqlite"
SQLITE_DB="$SQLITE_DIR/piscobox.db"

mkdir -p "$SQLITE_DIR"
chown -R www-data:www-data "$SQLITE_DIR"
chmod 755 "$SQLITE_DIR"

if [ ! -f "$SQLITE_DB" ]; then
    sudo -u www-data sqlite3 "$SQLITE_DB" "VACUUM;"
    print_success "SQLite database created: $SQLITE_DB"
else
    print_success "SQLite database already exists"
fi

# --------------------------------------------------
# 4. Create systemd service
# --------------------------------------------------
print_step 5 6 "Creating SQLite Web systemd service"

SERVICE_FILE="/etc/systemd/system/sqlite-web.service"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=SQLite Web
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/local/bin/sqlite_web $SQLITE_DB --host 127.0.0.1 --port 8082
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sqlite-web
systemctl restart sqlite-web

print_success "SQLite Web service enabled and running"

# --------------------------------------------------
# 5. Apache reverse proxy
# --------------------------------------------------
print_step 6 6 "Configuring Apache reverse proxy for SQLite Web"

APACHE_CONF="/etc/apache2/conf-available/sqlite-web.conf"

cat <<EOF > "$APACHE_CONF"
# SQLite Web reverse proxy

ProxyPreserveHost On

# --- Static assets MUST go first ---
ProxyPass        /static http://127.0.0.1:8082/static
ProxyPassReverse /static http://127.0.0.1:8082/static

# --- App ---
ProxyPass        /sqlite http://127.0.0.1:8082/
ProxyPassReverse /sqlite http://127.0.0.1:8082/

RequestHeader set X-Forwarded-Proto "http"
RequestHeader set X-Forwarded-Port "8080"

<Location /sqlite>
    Require all granted
</Location>

<Location /static>
    Require all granted
</Location>
EOF

a2enmod proxy proxy_http headers
a2enconf sqlite-web
systemctl reload apache2

print_success "SQLite Web available at /sqlite"
print_success "Finished at: $(date '+%Y-%m-%d %H:%M:%S')"
