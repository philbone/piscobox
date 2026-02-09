#!/bin/bash

# ============================================
# CREATE GLOBAL PHP CONFIG (PISCOBOX)
# ============================================

UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || true

GLOBAL_INI_SOURCE="/var/extra_data/php/global.ini"

print_header "CREATE GLOBAL PHP CONFIG (20-piscobox-global.ini)"

# --------------------------------------------
# Ensure source directory exists
# --------------------------------------------
sudo mkdir -p "$(dirname "$GLOBAL_INI_SOURCE")"

# --------------------------------------------
# Create global.ini template if missing
# --------------------------------------------
if [[ ! -f "$GLOBAL_INI_SOURCE" ]]; then
  print_warning "Global PHP config not found — creating template"

  sudo tee "$GLOBAL_INI_SOURCE" >/dev/null <<'EOF'
; PiscoBox global PHP configuration
; Edit this file on the host: ./extra_data/php/global.ini

memory_limit = 512M
upload_max_filesize = 100M
post_max_size = 100M
display_errors = Off
log_errors = On
error_reporting = E_ALL
EOF

  sudo chown www-data:www-data "$GLOBAL_INI_SOURCE" || true
  sudo chmod 664 "$GLOBAL_INI_SOURCE" || true

  print_success "Created $GLOBAL_INI_SOURCE"
else
  print_success "Found global PHP config at $GLOBAL_INI_SOURCE"
fi

# --------------------------------------------
# Detect installed PHP versions (single source)
# --------------------------------------------
PHP_VERSIONS=()

for d in /etc/php/*; do
  [[ -d "$d/fpm" ]] || continue
  PHP_VERSIONS+=( "$(basename "$d")" )
done

if [[ ${#PHP_VERSIONS[@]} -eq 0 ]]; then
  print_error "No PHP-FPM installations found under /etc/php"
  exit 1
fi

print_success "Detected PHP versions: ${PHP_VERSIONS[*]}"

# --------------------------------------------
# Create symlinks per PHP version
# --------------------------------------------
COUNT=0

for ver in "${PHP_VERSIONS[@]}"; do
  CONF_D="/etc/php/${ver}/fpm/conf.d"
  TARGET="${CONF_D}/20-piscobox-global.ini"

  if [[ ! -d "$CONF_D" ]]; then
    print_warning "PHP ${ver}: fpm/conf.d directory not found, skipping"
    continue
  fi

  sudo ln -sf "$GLOBAL_INI_SOURCE" "$TARGET" || {
    print_error "PHP ${ver}: failed to create symlink"
    continue
  }

  ((COUNT++))
  print_success "PHP ${ver}: global config linked"
done


print_success "Global PHP config installed for ${COUNT} PHP version(s)"

# --------------------------------------------
# Final hints
# --------------------------------------------
print_success "Reload PHP-FPM to apply changes:"
for ver in "${PHP_VERSIONS[@]}"; do
  echo "  sudo systemctl reload php${ver}-fpm 2>/dev/null || true"
done

exit 0
