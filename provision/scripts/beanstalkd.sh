#!/bin/bash
#
# ============================================
# BEANSTALKD INSTALLATION
# ============================================

UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || {
  echo "Error: Cannot load utilities"
  exit 1
}

# Initialize
init_timer
setup_error_handling

print_header "BEANSTALKD INSTALLATION"
print_success "Start at: $SCRIPT_START_TIME"
echo ""

print_warning "Ensuring system time is synchronized..."

if ! systemctl list-unit-files | grep -q systemd-timesyncd.service; then
  print_warning "systemd-timesyncd not found, installing..."
  run_apt_command "apt-get update -y"
  run_apt_command "apt-get install -y systemd-timesyncd"
fi

timedatectl set-ntp true
sudo systemctl enable systemd-timesyncd
sudo systemctl restart systemd-timesyncd

# Give it a moment to sync
sleep 2

# Install package
run_apt_command "apt-get update -y"
run_apt_command "apt-get install -y beanstalkd"

# Enable service on boot
systemctl enable beanstalkd

# Ensure default config listens locally
BEANSTALKD_DEFAULT="/etc/default/beanstalkd"

if [ -f "$BEANSTALKD_DEFAULT" ]; then
  print_warning "Configuring Beanstalkd defaults..."

  sed -i 's/^#\?START=.*/START=yes/' $BEANSTALKD_DEFAULT
  sed -i 's/^#\?BEANSTALKD_ADDR=.*/BEANSTALKD_ADDR=127.0.0.1/' $BEANSTALKD_DEFAULT
  sed -i 's/^#\?BEANSTALKD_PORT=.*/BEANSTALKD_PORT=11300/' $BEANSTALKD_DEFAULT
fi

# Restart service
systemctl restart beanstalkd

# Basic verification
if systemctl is-active --quiet beanstalkd; then
  print_success "Beanstalkd is running on 127.0.0.1:11300"
else
  print_error "Beanstalkd failed to start"
  exit 1
fi
