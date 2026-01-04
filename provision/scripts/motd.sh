#!/bin/bash

# =========================================="
#  MOTD CONFIGURATION (WELCOME MESSAGE)"
# =========================================="

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "CUSTOM MOTD"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Remove default motd
print_step 1 2 "Configuring custom MOTD..."
rm -f /etc/motd
rm -f /etc/update-motd.d/*

# Create custom MOTD
cat > /etc/motd <<'EOF'
                                                                                   
     ███████████   ███                            ███████████                      
    ▒▒███▒▒▒▒▒███ ▒▒▒                            ▒▒███▒▒▒▒▒███                     
     ▒███    ▒███ ████   █████   ██████   ██████  ▒███    ▒███  ██████  █████ █████
     ▒██████████ ▒▒███  ███▒▒   ███▒▒███ ███▒▒███ ▒██████████  ███▒▒███▒▒███ ▒▒███ 
     ▒███▒▒▒▒▒▒   ▒███ ▒▒█████ ▒███ ▒▒▒ ▒███ ▒███ ▒███▒▒▒▒▒███▒███ ▒███ ▒▒▒█████▒  
     ▒███         ▒███  ▒▒▒▒███▒███  ███▒███ ▒███ ▒███    ▒███▒███ ▒███  ███▒▒▒███ 
     █████        █████ ██████ ▒▒██████ ▒▒██████  ███████████ ▒▒██████  █████ █████
    ▒▒▒▒▒        ▒▒▒▒▒ ▒▒▒▒▒▒   ▒▒▒▒▒▒   ▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒  ▒▒▒▒▒ ▒▒▒▒▒ 
                                                                                   
                                          v0.1.0                   
        
    • Web Access:           http://192.168.56.110
    • From host:            http://localhost:8080    
    • SSH:                  vagrant ssh
    
    • Directories synchronized by default:
      /var/www/html/        → Web root 
      /var/extra_data/      → Secure data (outside of web root)
    
    • Database:
      DB: piscoboxdb | User: piscoboxuser | Pass: DevPassword123
    
    • PHP available:
      - PHP 8.3
      - PHP info    :       http://192.168.56.110/phpinfo.php  
    
    Quick commands:
      sudo systemctl restart apache2    # Restart Apache
      sudo tail -f /var/log/apache2/whmcs-error.log
      sudo mysql
    
EOF

print_step 2 2 "Adding network information to the MOTD..."
IP_ADDR=$(ip addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
echo "" >> /etc/motd
echo "    Machine IP address: $IP_ADDR" >> /etc/motd

print_success "✅ MOTD configured"