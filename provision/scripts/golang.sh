#!/bin/bash

# ============================================
# GOLANG INSTALLATION
# ============================================

# Load utilities
UTILS_FILE="/vagrant/provision/scripts/bash-utils.sh"
[ -f "$UTILS_FILE" ] && source "$UTILS_FILE" || { echo "Error: Cannot load utilities"; exit 1; }

# Initialize
init_timer
setup_error_handling

# Configuration
GO_VERSION="latest"
GO_DOWNLOAD_URL="https://go.dev/dl"
GO_INSTALL_PATH="/usr/local/go"
GO_PATH="/go"
GO_BIN_PATH="$GO_INSTALL_PATH/bin"

# Display header
print_header "GOLANG INSTALLATION"
echo "Start at: $SCRIPT_START_TIME"
echo ""

# Step 1: Check if already installed
print_step 1 6 "Checking for existing Go installation..."
if command -v go &> /dev/null; then
    EXISTING_VERSION=$(go version | awk '{print $3}')
    print_warning "Go is already installed: $EXISTING_VERSION"
    echo "Proceeding with installation to ensure latest stable version..."
else
    print_success "No existing Go installation found"
fi
echo ""

# Step 2: Determine latest version
print_step 2 6 "Fetching latest Go version..."
LATEST_VERSION=$(curl -s "https://go.dev/dl/?mode=json" | grep -o '"version":"go[^"]*"' | head -1 | sed 's/"version":"\|"//g')
if [ -z "$LATEST_VERSION" ]; then
    LATEST_VERSION="go1.25.4"  # Fallback to stable version
    print_warning "Using fallback version: $LATEST_VERSION"
else
    print_success "Latest Go version available: $LATEST_VERSION"
fi
echo ""

# Step 3: Download latest Go
print_step 3 6 "Downloading Go $LATEST_VERSION for Linux amd64..."
GO_ARCHIVE="$LATEST_VERSION.linux-amd64.tar.gz"
GO_URL="$GO_DOWNLOAD_URL/$GO_ARCHIVE"

cd /tmp || exit 1
if [ -f "$GO_ARCHIVE" ]; then
    print_warning "Archive already exists, skipping download"
else
    if curl -fsSL -o "$GO_ARCHIVE" "$GO_URL"; then
        print_success "Downloaded $GO_ARCHIVE"
    else
        print_error "Failed to download Go from $GO_URL"
        exit 1
    fi
fi
echo ""

# Step 4: Remove old installation and install new
print_step 4 6 "Installing Go to $GO_INSTALL_PATH..."
if [ -d "$GO_INSTALL_PATH" ]; then
    print_warning "Removing previous Go installation..."
    rm -rf "$GO_INSTALL_PATH"
fi

tar -xzf "$GO_ARCHIVE" -C /usr/local/ || { print_error "Failed to extract Go archive"; exit 1; }
print_success "Go extracted successfully"
echo ""

# Step 5: Configure environment variables
print_step 5 6 "Configuring Go environment variables..."

# Ensure GOPATH directory exists
if [ ! -d "$GO_PATH" ]; then
    mkdir -p "$GO_PATH"
    print_success "Created GOPATH directory: $GO_PATH"
fi

# Create bash profile configuration
GO_PROFILE_FILE="/etc/profile.d/golang.sh"
cat > "$GO_PROFILE_FILE" <<'EOF'
# Go environment variables
export GOROOT=/usr/local/go
export GOPATH=/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
EOF

chmod 644 "$GO_PROFILE_FILE"
print_success "Created Go profile configuration: $GO_PROFILE_FILE"

# Source the profile immediately for current session
source "$GO_PROFILE_FILE"
print_success "Go environment variables configured"
echo ""

# Step 6: Verification
print_step 6 6 "Verifying installation..."
echo ""

GO_VERSION_OUTPUT=$(go version)
if [ $? -eq 0 ]; then
    print_success "Go version: $GO_VERSION_OUTPUT"
else
    print_error "Go version check failed"
    exit 1
fi

echo "GOROOT: $GOROOT"
echo "GOPATH: $GOPATH"
echo "Go executable: $(which go)"
echo ""

# Additional Go tools
print_info "Installing common Go tools..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>&1 | grep -E "go:|error" || true
print_success "Go environment setup complete!"
echo ""

# Cleanup
rm -f /tmp/"$GO_ARCHIVE"

# Final summary
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
ELAPSED=$(calculate_elapsed_time "$SCRIPT_START_TIME" "$END_TIME")
echo -e "${SUCCESS_COLOR}╔════════════════════════════════════════╗${NC}"
echo -e "${SUCCESS_COLOR}║    GOLANG INSTALLATION COMPLETE        ║${NC}"
echo -e "${SUCCESS_COLOR}╚════════════════════════════════════════╝${NC}"
echo "Completed at: $END_TIME"
echo "Total time: $ELAPSED"
echo ""
