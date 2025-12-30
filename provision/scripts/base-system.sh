#!/bin/bash

# ============================================
# BASE SYSTEM CONFIGURATION FOR VAGRANT
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

# Step 1: Update system
print_step 1 4 "Updating system"
run_apt_command "apt-get update"

if [ $? -eq 0 ]; then
    print_step 2 4 "Upgrading system"
    #run_apt_command "apt-get upgrade -y"
    print_success "System updated successfully"
else    
    print_error "Cannot proceed with system update"
    exit 1
fi
echo ""

# Step 2: Install basic tools
print_step 3 4 "Installing basic tools"
run_apt_command "apt-get install -y wget curl gnupg lsb-release ca-certificates net-tools git vim"
print_success "Basic tools installed successfully"
echo ""

# Step 3: Configure Locale and TimeZone
print_step 4 4 "Setting Locale and TimeZone"
timedatectl set-timezone UTC
localectl set-locale LANG=C.UTF-8
print_success "Locale and TimeZone configured successfully"
echo ""

# Show final success message
show_success_message