#!/bin/bash
#
# ============================================
# POSTGRESQL INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "POSTGRESQL INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

# -----------------------------
# Variables
# -----------------------------
PG_VERSION="16"
PG_USER="piscoboxuser"
PG_PASSWORD="DevPassword123"
PG_DB="piscoboxdb"

# -----------------------------
# Add PostgreSQL official repo
# -----------------------------
if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
  print_step 1 10 "==> Adding PostgreSQL APT repository..."
  run_apt_command "apt-get update"
  run_apt_command "apt-get install -y wget ca-certificates gnupg"

  wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor \
    | tee /usr/share/keyrings/postgresql.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list
fi

run_apt_command "apt-get update"

# -----------------------------
# Install PostgreSQL 16
# -----------------------------
print_step 2 10 "==> Instalando PostgreSQL..."
run_apt_command "apt-get install -y \
  postgresql-${PG_VERSION} \
  postgresql-client-${PG_VERSION} \
  postgresql-contrib"

# -----------------------------
# Enable & start service
# -----------------------------
print_step 3 10 "==> Habilitando el servicio PostgreSQL..."
systemctl enable postgresql
print_step 4 10 "==> Iniciando el servicio PostgreSQL..."
systemctl start postgresql

# -----------------------------
# Basic configuration
# -----------------------------
print_step 5 10 "==> Creando configuración básica..."
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

# listen only on localhost
print_step 6 10 "==> Restringiendo acceso a solamente localhost..."
sed -i "s/^#listen_addresses =.*/listen_addresses = 'localhost'/" "$PG_CONF"

# Ensure md5 auth for local TCP
print_step 7 10 "==> Configuring local auth to use md5..."
grep -q "127.0.0.1/32" "$PG_HBA" || cat <<EOF >> "$PG_HBA"
host    all     all     127.0.0.1/32    md5
host    all     all     ::1/128         md5
EOF

sed -i "s/^local\s\+all\s\+all\s\+peer/local all all md5/" "$PG_HBA"

print_step 8 10 "==> Reiniciando PostgreSQL..."
systemctl restart postgresql

# -----------------------------
# Create user & database
# -----------------------------
print_step 9 10 "==> Creating default user and database..."

# Create role if not exists
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = '${PG_USER}'
  ) THEN
    CREATE ROLE ${PG_USER} LOGIN PASSWORD '${PG_PASSWORD}';
  END IF;
END
\$\$;
EOF

# Create database if not exists (must be outside DO block)
DB_EXISTS=$(sudo -u postgres psql -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${PG_DB}'")

if [ "$DB_EXISTS" != "1" ]; then
  sudo -u postgres createdb -O "${PG_USER}" "${PG_DB}"
fi

# -----------------------------
# Smoke tests
# -----------------------------
print_step 10 10 "==> Smoke tests..."
psql --version
systemctl is-active postgresql >/dev/null && echo "✔ PostgreSQL is running"

print_success "✔ PostgreSQL ${PG_VERSION} ready"
