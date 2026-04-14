#!/bin/bash

# ============================================
# PYTHON DUAL SUPPORT INSTALLATION
# Python 3 (default) + Python 2.7 (legacy)
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Display header
print_header "PYTHON DUAL SUPPORT INSTALLATION"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Step 1: Update package manager
print_step 1 7 "Updating package manager..."
apt-get update -qq
print_success "Package manager updated"
echo ""

# Step 2: Install Python 3
print_step 2 7 "Installing Python 3..."
if apt-get install -y python3 python3-pip python3-venv python3-dev &> /dev/null; then
    PY3_VERSION=$(python3 --version)
    print_success "$PY3_VERSION installed"
    
    # Create alias for python3
    ln -sf /usr/bin/python3 /usr/local/bin/python30 2>/dev/null || true
    
    # Get specific version for alias
    PY3_MINOR=$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')
    if [ -f "/usr/bin/python3.${PY3_MINOR:1}" ]; then
        ln -sf /usr/bin/python3.${PY3_MINOR:1} /usr/local/bin/python${PY3_MINOR} 2>/dev/null || true
    fi
else
    print_error "Failed to install Python 3"
    exit 1
fi
echo ""

# Step 3: Install Python 2.7
print_step 3 7 "Installing Python 2.7..."
if apt-get install -y python2 &> /dev/null; then
    PY2_VERSION=$(python2 --version 2>&1)
    print_success "$PY2_VERSION installed"
    
    # Create alias for python2
    ln -sf /usr/bin/python2 /usr/local/bin/python20 2>/dev/null || true
    ln -sf /usr/bin/python2.7 /usr/local/bin/python27 2>/dev/null || true
else
    print_error "Failed to install Python 2.7"
    print_warning "Continuing with Python 3 only..."
fi
echo ""

# Step 4: Install pip for Python 2.7
print_step 4 7 "Installing pip for Python 2.7..."
if command -v python2 &> /dev/null; then
    # Download and install get-pip.py for Python 2.7
    cd /tmp || exit 1
    if curl -fsSL -o get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py 2>/dev/null; then
        python2 get-pip.py &> /dev/null
        if command -v pip2 &> /dev/null; then
            print_success "pip for Python 2.7 installed"
            ln -sf /usr/local/bin/pip2 /usr/local/bin/pip20 2>/dev/null || true
            ln -sf /usr/local/bin/pip2 /usr/local/bin/pip27 2>/dev/null || true
        else
            print_warning "pip2 installation had issues, continuing..."
        fi
        rm -f get-pip.py
    else
        print_warning "Could not download get-pip for Python 2.7, skipping..."
    fi
else
    print_info "Python 2.7 not available, skipping pip2"
fi
echo ""

# Step 5: Upgrade pip for Python 3
print_step 5 7 "Upgrading pip for Python 3..."
python3 -m pip install --upgrade pip setuptools wheel -q 2>/dev/null || true
if command -v pip3 &> /dev/null; then
    print_success "pip3 upgraded"
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip30 2>/dev/null || true
    
    # Get specific version for alias
    PY3_MINOR=$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')
    if [ -f "/usr/local/bin/pip3.${PY3_MINOR:1}" ] || [ -f "/usr/bin/pip3.${PY3_MINOR:1}" ]; then
        ln -sf /usr/local/bin/pip3.${PY3_MINOR:1} /usr/local/bin/pip${PY3_MINOR} 2>/dev/null || true
    fi
else
    print_warning "pip3 not found in expected location"
fi
echo ""

# Step 6: Create profile configuration
print_step 6 7 "Configuring Python environment variables..."
PYTHON_PROFILE_FILE="/etc/profile.d/python.sh"
cat > "$PYTHON_PROFILE_FILE" <<'EOF'
# Python environment variables
export PYTHONPATH=/usr/local/lib/python3/site-packages:/usr/lib/python3/site-packages

# Python version aliases for easy access
# Usage: python30 (Python 3), python27 (Python 2.7), etc.
EOF

chmod 644 "$PYTHON_PROFILE_FILE"
print_success "Python profile configuration created"
echo ""

# Step 7: Verification
print_step 7 7 "Verifying installation..."
echo ""

# Python 3
if command -v python3 &> /dev/null; then
    print_success "Python 3: $(python3 --version)"
    print_info "Aliases: python30, python3X (where X is minor version)"
else
    print_error "Python 3 not found"
fi

# Python 2.7
if command -v python2 &> /dev/null; then
    print_success "Python 2.7: $(python2 --version 2>&1)"
    print_info "Aliases: python27, python20"
fi

# pip3
if command -v pip3 &> /dev/null; then
    PIP3_VERSION=$(pip3 --version | awk '{print $2}')
    print_success "pip3 (v$PIP3_VERSION)"
    print_info "Aliases: pip30, pip3X (where X is minor version)"
fi

# pip2
if command -v pip2 &> /dev/null; then
    PIP2_VERSION=$(pip2 --version 2>&1 | awk '{print $2}')
    print_success "pip2 (v$PIP2_VERSION)"
    print_info "Aliases: pip27, pip20"
fi

echo ""
echo "Common packages to install: requests, flask, django, numpy, pandas"
echo ""

# Final summary
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
ELAPSED=$(calculate_elapsed_time "$SCRIPT_START_TIME" "$END_TIME")
echo -e "${SUCCESS_COLOR}╔════════════════════════════════════════╗${NC}"
echo -e "${SUCCESS_COLOR}║    PYTHON INSTALLATION COMPLETE        ║${NC}"
echo -e "${SUCCESS_COLOR}╚════════════════════════════════════════╝${NC}"
echo "Completed at: $END_TIME"
echo "Total time: $ELAPSED"
echo ""
