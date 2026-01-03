#!/bin/bash

# ============================================
# MARIADB DATABASE
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "DATABASE MARIADB"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Install MariaDB
print_step 1 5 "Installing MariaDB..."
run_apt_command "apt-get install -y mariadb-server mariadb-client"
if [ $? -eq 0 ];then
    systemctl start mariadb
    systemctl enable mariadb
else
    print_error "Error installing MariaDB"
fi
echo ""

# Wait for MariaDB to be ready
print_step 2 5 "Waiting for MariaDB initialization..."
sleep 3
if [ $? -eq 0 ]; then
    print_success "MariaDB initialized."
else
    print_error "Error initializing MariaDB"
fi

# Create database
print_step 3 5 "Creating a PiscoBox database..."
mysql -e "CREATE DATABASE IF NOT EXISTS piscoboxdb CHARACTER SET latin1 COLLATE latin1_swedish_ci;" 2>/dev/null || true
if [ $? -eq 0 ]; then
    print_success "piscoboxdb database created"
else
    print_error "Error creating the piscoboxdb database"
fi

# Create user
print_step 4 5 "Creating a PiscoBox user..."
mysql -e "CREATE USER IF NOT EXISTS 'piscoboxuser'@'localhost' IDENTIFIED BY 'DevPassword123';" 2>/dev/null || true
if [ $? -eq 0 ]; then
    print_success "Database user piscoboxuser created"
else
    print_error "Error creating database user"
fi

# Granting privileges
mysql -e "GRANT ALL PRIVILEGES ON piscoboxdb.* TO 'piscoboxuser'@'localhost';" 2>/dev/null || true
if [ $? -eq 0 ]; then
    print_success "Privileges granted to piscoboxuser"
else
    print_error "Error granting permissions to user piscoboxuser"
fi

# Reload the changes
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
if [ $? -eq 0 ]; then
    print_success "The changes have taken effect"
else
    print_error "Error when trying to apply the changes"
fi

# Import backup if it exists
print_step 5 5 "Verifying backup for import..."
for BACKUP_PATH in "/vagrant/extra_data/backup.sql" "/vagrant/backup.sql" "/vagrant/provision/files/backup.sql"; do
    if [ -f "$BACKUP_PATH" ]; then
        echo "  → Importing backup: $BACKUP_PATH"
        mysql --default-character-set=latin1 whmcsdb < "$BACKUP_PATH" 2>/dev/null && \
        if [ $? -eq 0 ]; then
            print_success "The backup has been imported"
        else
            print_error  "An error occurred while importing the backup"
        fi         
        break
    else
        print_warning "No database was found to import in $BACKUP_PATH"
    fi
done

# Show version
mysql -V
if [ $? -eq 0 ]; then
    print_success "MariaDB ready and configured"
else
    print_error "Error installing MariaDB"
fi

# Print Credentials
print_header "MariaDB Credentials"
echo "user      : piscoboxuser"
echo "pass      : DevPassword123"
echo "database  : piscoboxdb"
echo ""
echo -e "${NC}To login as piscoboxuser: ${SUCCESS_COLOR}mysql -u piscoboxuser -p${NC} (and enter the pass)"
echo ""
echo -e "${NC}To log into MySQL as root: ${SUCCESS_COLOR}sudo mysql${NC} (no password needed)"
echo ""