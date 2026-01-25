#!/bin/bash

# ============================================
# PGADMIN INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "PGADMIN INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

# Paso 1
print_step 1 7 "==> Installing pgAdmin 4..."
echo ""

# --------------------------------------------
# Variables configurables (IMPORTANTE)
# --------------------------------------------
PGADMIN_EMAIL=${PGADMIN_EMAIL:-admin@piscobox.com}
PGADMIN_PASSWORD=${PGADMIN_PASSWORD:-DevPassword123}

# ⚠️ pgAdmin REQUIERE que estén EXPORTADAS
export PGADMIN_DEFAULT_EMAIL="${PGADMIN_EMAIL}"
export PGADMIN_DEFAULT_PASSWORD="${PGADMIN_PASSWORD}"
export PGADMIN_SETUP_EMAIL="${PGADMIN_EMAIL}"
export PGADMIN_SETUP_PASSWORD="${PGADMIN_PASSWORD}"

# Validación básica
[[ "$PGADMIN_EMAIL" == *@*.* ]] || {
  print_error "Invalid PGADMIN_EMAIL"
  exit 1
}

# --------------------------------------------
# Dependencias
# --------------------------------------------
run_apt_command "apt-get update"
run_apt_command "apt-get install -y curl ca-certificates gnupg apache2-utils"

# --------------------------------------------
# Repositorio oficial pgAdmin
# --------------------------------------------
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
  | gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg

echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/bookworm pgadmin4 main" \
  > /etc/apt/sources.list.d/pgadmin4.list

run_apt_command "apt-get update"
run_apt_command "apt-get install -y pgadmin4-web"

# --------------------------------------------
# Inicialización NO interactiva real
# --------------------------------------------
/usr/pgadmin4/bin/setup-web.sh --yes

# --------------------------------------------
# Recargar Apache (pgAdmin es WSGI)
# --------------------------------------------
systemctl restart apache2

print_success "✔ pgAdmin 4 installed"
print_success "→ URL: http://localhost:8080/pgadmin4"
print_success "→ User: ${PGADMIN_EMAIL}"
