#!/bin/bash
#
# ============================================
# SQLITE INSTALLATION
# ============================================

UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

print_header "INSTALLING SQLITE3"
echo "Start at: $SCRIPT_START_TIME"
echo ""

print_step 1 3 "Updating system"
run_apt_command "apt-get update"

print_step 2 3 "Installing basic tools"
run_apt_command "apt-get install -y sqlite3 libsqlite3-dev"

print_success "SQLite3 installed"

# Enable SQLite extensions for all installed PHP versions
print_step 3 3 "Enable SQLite extensions for detected PHP versions"
PHP_VERSIONS=$(detect_php_versions) || exit 1
for PHP_VER in $PHP_VERSIONS; do
    run_apt_command "apt-get install php${PHP_VER}-sqlite3"
    print_success "php${PHP_VER}-sqlite3 enabled"
done

print_success "SQLite version:"
sqlite3 --version
