#!/bin/bash

# ============================================
# BASH UTILITIES FOR VAGRANT PROVISIONING
# ============================================

# Color definitions - consistent across all scripts
TITLE_COLOR='\e[33m'       # Yellow for titles
SUCCESS_COLOR='\e[96m'     # Bright cyan for success
ERROR_COLOR='\e[91m'       # Bright red for errors
WARNING_COLOR='\e[93m'     # Bright yellow for warnings
NC='\e[0m'                 # No Color

# Global variables for state management
export SCRIPT_START_TIME=""
export APT_TEMP_LOG=""
export ERROR_OCCURRED=false

# ============================================
# TIME MANAGEMENT FUNCTIONS
# ============================================

# Calculate elapsed time in human readable format
# Usage: calculate_elapsed_time "start_time" "end_time"
calculate_elapsed_time() {
    local start_time="$1"
    local end_time="$2"
    
    # Validate parameters
    [ -z "$start_time" ] || [ -z "$end_time" ] && echo "N/A" && return 1
    
    # Convert to seconds since epoch
    local start_seconds end_seconds elapsed
    start_seconds=$(date -d "$start_time" +%s 2>/dev/null)
    end_seconds=$(date -d "$end_time" +%s 2>/dev/null)
    
    [ -z "$start_seconds" ] || [ -z "$end_seconds" ] && echo "Invalid time" && return 1
    
    elapsed=$((end_seconds - start_seconds))
    [ $elapsed -lt 0 ] && echo "Negative time" && return 1
    
    # Calculate components
    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    local seconds=$((elapsed % 60))
    
    # Format output appropriately
    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $seconds
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

# Initialize script timer and setup
init_timer() {
    SCRIPT_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    APT_TEMP_LOG="/tmp/apt_script_$$.log"
    ERROR_OCCURRED=false
}

# Get elapsed time from script start
get_elapsed_time() {
    [ -n "$SCRIPT_START_TIME" ] && calculate_elapsed_time "$SCRIPT_START_TIME" "$(date '+%Y-%m-%d %H:%M:%S')" || echo "N/A"
}

# ============================================
# ERROR HANDLING FUNCTIONS
# ============================================

# Main error handler - called via trap
error_handler() {
    local exit_code=$?
    local command="$BASH_COMMAND"
    local line_no="$1"
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Don't handle successful exits
    [ $exit_code -eq 0 ] && return
    
    ERROR_OCCURRED=true
    
    # Display error header
    echo "" && echo -e "${ERROR_COLOR}╔════════════════════════════════════════╗${NC}"
    echo -e "${ERROR_COLOR}║           ERROR DETECTED               ║${NC}"
    echo -e "${ERROR_COLOR}╚════════════════════════════════════════╝${NC}" && echo ""
    
    # Error details
    echo -e "${ERROR_COLOR}• Failed command:${NC} $command"
    echo -e "${ERROR_COLOR}• Line:${NC} $line_no"
    echo -e "${ERROR_COLOR}• Exit code:${NC} $exit_code"
    
    # Show elapsed time
    local elapsed_time
    elapsed_time=$([ -n "$SCRIPT_START_TIME" ] && calculate_elapsed_time "$SCRIPT_START_TIME" "$end_time" || echo "N/A")
    echo -e "${ERROR_COLOR}• Execution time:${NC} $elapsed_time"
    
    # Show APT specific errors if applicable
    if [[ "$command" == *"apt-get"* ]] && [ -f "$APT_TEMP_LOG" ]; then
        echo -e "${ERROR_COLOR}• APT output (last errors):${NC}"
        grep -iE "(failed|error|unable|temporary|cannot|unreachable)" "$APT_TEMP_LOG" | tail -3 | sed 's/^/  /'
    fi
    
    echo "" && echo -e "${ERROR_COLOR}════════════════════════════════════════${NC}"
    
    cleanup_temp_files
    exit $exit_code
}

# Setup error handling trap
setup_error_handling() {
    trap 'error_handler $LINENO' ERR
}

# ============================================
# APT COMMAND FUNCTIONS
# ============================================

# Execute apt commands with enhanced logging and network error detection
# Usage: run_apt_command "apt-get update"
run_apt_command() {
    local cmd="$1"
    echo -e "${TITLE_COLOR}Executing:${NC} $cmd"
    
    # Ensure temp log exists
    [ -z "$APT_TEMP_LOG" ] && APT_TEMP_LOG="/tmp/apt_script_$$.log"
    
    # Run command and capture output
    eval "$cmd" 2>&1 | tee "$APT_TEMP_LOG"
    local exit_code=${PIPESTATUS[0]}
    
    # Check for network-related errors (even if exit code is 0)
    if grep -q -iE "(failed to fetch|temporary failure|could not resolve|unable to fetch|unreachable)" "$APT_TEMP_LOG"; then
        echo -e "${WARNING_COLOR}⚠️  Network issues detected${NC}"
        
        # In non-interactive mode (Vagrant), treat network errors as failures
        if [ ! -t 0 ]; then
            echo -e "${ERROR_COLOR}Network error in non-interactive mode${NC}"
            return 1
        fi
    fi
    
    return $exit_code
}

# ============================================
# APACHE MODS
# ============================================

# Search for enabled modules
search_apache_mods_enabled() {
    
    #ls /etc/apache2/mods-enabled/ | grep -E "(rewrite|headers|expires|include|ipblock)\.load"

    # Or to see both, enabled and available
    for modulo in rewrite headers expires include proxy nomy; do
        echo -n "Module $modulo: "
        if [ -f /etc/apache2/mods-enabled/${modulo}.load ]; then
            print_success "ACTIVATED"
        elif [ -f /etc/apache2/mods-available/${modulo}.load ]; then
            print_warning "AVAILABLE (but not activated)"
        else
            print_error "NOT INSTALLED"
        fi
    done
}

# ============================================
# CLEANUP FUNCTIONS
# ============================================

# Cleanup temporary files
cleanup_temp_files() {
    [ -f "$APT_TEMP_LOG" ] && rm -f "$APT_TEMP_LOG" 2>/dev/null
}

# Show final success message with timing
show_success_message() {
    local elapsed_time=$(get_elapsed_time)
    
    cleanup_temp_files
    
    echo -e "${TITLE_COLOR}════════════════════════════════════════${NC}"
    echo -e "${SUCCESS_COLOR}✅ Operation completed successfully${NC}"
    echo -e "${TITLE_COLOR}Total execution time:${NC} $elapsed_time"
    echo -e "${TITLE_COLOR}════════════════════════════════════════${NC}"
}

# ============================================
# PRINTING FUNCTIONS
# ============================================

# Print section header
# Usage: print_header "TITLE"
print_header() {
    local title="$1"
    echo "" && echo -e "${TITLE_COLOR}==========================================${NC}"
    echo -e "${TITLE_COLOR}      $title${NC}"
    echo -e "${TITLE_COLOR}==========================================${NC}"
}

# Print step with progress indicator
# Usage: print_step 1 3 "Updating system"
print_step() {
    local step_num="$1"
    local step_total="$2"
    local message="$3"
    echo -e "${TITLE_COLOR}[$step_num/$step_total] $message...${NC}"
}

# Print success message
# Usage: print_success "Operation completed"
print_success() {
    echo -e "${SUCCESS_COLOR}✓ $1${NC}"
}

# Print error message
# Usage: print_error "Something failed"
print_error() {
    echo -e "${ERROR_COLOR}✗ $1${NC}"
}

# Print warning message
# Usage: print_warning "Potential issue"
print_warning() {
    echo -e "${WARNING_COLOR}⚠ $1${NC}"
}

# --------------------------------------------
# Detect installed PHP versions
# --------------------------------------------
detect_php_versions() {
    local PHP_BASE_DIR="/etc/php"
    local PHP_VERSIONS=()

    print_step 1 1 "Detecting installed PHP versions..." >&2

    if [ ! -d "$PHP_BASE_DIR" ]; then
        print_error "PHP base directory not found: $PHP_BASE_DIR" >&2
        return 1
    fi

    for dir in "$PHP_BASE_DIR"/*; do
        [ -d "$dir" ] && PHP_VERSIONS+=("$(basename "$dir")")
    done

    if [ ${#PHP_VERSIONS[@]} -eq 0 ]; then
        print_error "No PHP versions detected under $PHP_BASE_DIR" >&2
        return 1
    fi

    echo "${PHP_VERSIONS[@]}"
}
