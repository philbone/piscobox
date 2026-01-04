#!/bin/bash

# ============================================
# APACHE 2 INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "BASE SYSTEM AND REPOSITORIES"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Install Apache
print_step 1 9 "Installing Apache..."
run_apt_command "apt-get install -y apache2"
echo ""

if [ $? -eq 0 ]; then
    print_step 2 9 "Configuring Apache modules"
    a2dismod mpm_event 2>/dev/null || true
    a2enmod mpm_prefork rewrite
    print_success "Apache installed successfully"
else    
    print_error "Cannot proceed with apache instalation"
    exit 1
fi
echo ""

# Create web directory if it does not exist
print_step 3 9 "Configuring the web directory..."
mkdir -p /var/www/html/
if [ $? -eq 0 ]; then
    print_success "Web directory ready"
else 
    print_error "Error attempting to configure the web directory"
    exit 1
fi
echo ""

# VirtualHost
print_step 4 9 "Creating VirtualHost for PiscoBox..."
cat > /etc/apache2/sites-available/public_html.conf <<'EOF'
<VirtualHost *:80>
    ServerName piscobox-dev.local
    DocumentRoot /var/www/html/
    
    # PHP-FPM CONFIGURATION - REQUIRED FOR PHP PROCESSING
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost"
    </FilesMatch>
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Block access to secure directories
    <Directory /var/extra_data>
        Require all denied
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/piscobox-error.log
    CustomLog ${APACHE_LOG_DIR}/piscobox-access.log combined
</VirtualHost>
EOF

if [ $? -eq 0 ]; then
    print_success "VirtualHost created"
else 
    print_error "Error attempting to create VirtualHost"
    exit 1
fi
echo ""

# Enable site and disable default
print_step 5 9 "Enabling the PiscoBox site..."
a2dissite 000-default.conf 2>/dev/null || true
if [ $? -eq 0 ]; then
    print_success "VirtualHost for 000-default.conf disabled"
else 
    print_error "Error disabling 000-default.conf"
    exit 1
fi

a2ensite public_html.conf
if [ $? -eq 0 ]; then
    print_success "VirtualHost enabled for public_html.conf"
else 
    print_error "Error trying to enable public_html.conf"
    exit 1
fi

a2enmod rewrite headers expires include
if [ $? -eq 0 ]; then
    print_success "Activated modules: rewrite, headers, expires and include"
else
    print_error "Error activating additional modules"
fi
search_apache_mods_enabled 
echo ""
print_success "✅ Apache configured"
echo ""

# Configure permissions
print_step 6 9 "Configuring permissions..."
chown -R www-data:www-data /var/extra_data
if [ $? -eq 0 ]; then
    print_success "Owner successfully assigned /var/extra_data"
else
    print_error "Error assigning owner /var/extra_data"
    exit 1
fi

chmod -R 750 /var/extra_data
if [ $? -eq 0 ]; then
    print_success "750 assigned recursively /var/extra_data"
else
    print_error "Error assigning permission 750 /var/extra_data"
    exit 1
fi

chmod 770 /var/extra_data/
if [ $? -eq 0 ]; then
    print_success "770 successfully assigned /var/extra_data"
else
    print_error "Error assigning permission 770 /var/extra_data"
    exit 1
fi
echo ""


# Configure web directory permissions
print_step 7 9 "Configuring web directory permissions..."
chown -R www-data:www-data /var/www/html
if [ $? -eq 0 ]; then
    print_success "Owner correctly assigned /var/www/html"
else
    print_error "Error assigning owner /var/www/html"
    exit 1
fi
print_success "✅ Configured directories"
echo ""

print_step 8 9 "Restarting Apache..."
systemctl restart apache2

if [ $? -eq 0 ]; then
    print_success "Apache restarted"
else
    print_error "Error trying to restart Apache"
fi
echo ""

print_step 9 9 "Verifying services..."
sleep 2

if systemctl is-active --quiet apache2; then
    print_success "✅ Apache active"
else
    print_error "❌ Apache inactive"
fi

print_success "✅ Services restarted"