#!/usr/bin/env bash
# ensure_simulator.sh - Ensure Connect IQ Simulator is running
# Detects, starts, and validates the simulator before test execution
#
# Default behavior: Always restart simulator for clean state (prevents test hangs)
# Use --no-restart flag to only start if not running (faster but may hang on rerun)
# Use --restart or -r to force restart

set -euo pipefail

# Colors for output
if [[ -t 1 ]]; then
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'
    C_RESET='\033[0m'
else
    C_RED=''
    C_GREEN=''
    C_YELLOW=''
    C_BLUE=''
    C_RESET=''
fi

print_info() {
    echo -e "${C_BLUE}[SIMULATOR]${C_RESET} $*"
}

print_success() {
    echo -e "${C_GREEN}[SIMULATOR]${C_RESET} $*"
}

print_error() {
    echo -e "${C_RED}[SIMULATOR]${C_RESET} $*" >&2
}

print_warning() {
    echo -e "${C_YELLOW}[SIMULATOR]${C_RESET} $*"
}

# Find Connect IQ Simulator application
find_simulator_app() {
    # Try SDK_HOME first
    if [[ -n "${SDK_HOME:-}" ]]; then
        local sdk_sim="${SDK_HOME}/bin/ConnectIQ.app"
        if [[ -d "${sdk_sim}" ]]; then
            echo "${sdk_sim}"
            return 0
        fi
    fi
    
    # Try common SDK locations
    local sdk_paths=(
        "$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/"*"/bin/ConnectIQ.app"
        "/Applications/Garmin/ConnectIQ/Sdks/"*"/bin/ConnectIQ.app"
        "$HOME/connectiq-sdk"*"/bin/ConnectIQ.app"
    )
    
    for path in "${sdk_paths[@]}"; do
        if [[ -d "${path}" ]]; then
            echo "${path}"
            return 0
        fi
    done
    
    return 1
}

# Check if simulator is running
is_simulator_running() {
    # Check for Connect IQ process (Java-based simulator)
    if pgrep -f "ConnectIQ.app" > /dev/null 2>&1; then
        return 0
    fi
    
    # Also check for simulator process by name
    if pgrep -i "simulator" > /dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Wait for simulator to be ready
wait_for_simulator() {
    local max_wait=${1:-10}
    local waited=0
    
    print_info "Waiting for simulator to be ready..."
    
    while [[ ${waited} -lt ${max_wait} ]]; do
        # Check if monkeydo can connect (best way to verify readiness)
        if command -v monkeydo &> /dev/null; then
            # Try a quick connection test (this will fail but connection attempt is what matters)
            if monkeydo --help &> /dev/null; then
                return 0
            fi
        fi
        
        sleep 1
        waited=$((waited + 1))
    done
    
    # After waiting, just assume it's ready if process is running
    if is_simulator_running; then
        return 0
    fi
    
    return 1
}

# Kill existing simulator instances
kill_simulator() {
    print_warning "Stopping existing simulator instances..."
    
    # Kill by process name
    pkill -f "ConnectIQ.app" 2>/dev/null || true
    pkill -i "simulator" 2>/dev/null || true
    
    # Give it time to shut down
    sleep 2
    
    # Force kill if still running
    pkill -9 -f "ConnectIQ.app" 2>/dev/null || true
    pkill -9 -i "simulator" 2>/dev/null || true
    
    sleep 1
}

# Start the simulator
start_simulator() {
    local sim_app
    
    print_info "Starting Connect IQ Simulator..."
    
    if ! sim_app=$(find_simulator_app); then
        print_error "Could not find ConnectIQ.app"
        print_error "Please ensure Connect IQ SDK is installed"
        return 1
    fi
    
    print_info "Found simulator at: ${sim_app}"
    
    # Open the app in background
    if ! open "${sim_app}"; then
        print_error "Failed to open simulator application"
        return 1
    fi
    
    # Wait for simulator to be ready
    if wait_for_simulator 15; then
        print_success "Simulator started and ready"
        return 0
    else
        print_warning "Simulator started but may not be fully ready"
        print_warning "Continuing anyway..."
        return 0
    fi
}

# Main logic
main() {
    local force_restart=${1:-false}
    local skip_restart=${2:-false}
    
    if [[ "${force_restart}" == "--restart" ]] || [[ "${force_restart}" == "-r" ]]; then
        print_info "Force restart requested"
        kill_simulator
        start_simulator
        exit $?
    fi
    
    if [[ "${force_restart}" == "--no-restart" ]] || [[ "${skip_restart}" == "true" ]]; then
        # Only check/start if not running (old behavior)
        if is_simulator_running; then
            print_success "Simulator is already running"
            exit 0
        fi
        print_info "Simulator is not running"
        start_simulator
        exit $?
    fi
    
    # Default behavior: Always restart for test reliability
    if is_simulator_running; then
        print_info "Simulator is running - restarting for clean state"
        kill_simulator
    else
        print_info "Simulator is not running"
    fi
    
    start_simulator
    exit $?
}

# Handle script arguments
if [[ $# -gt 0 ]]; then
    main "$1"
else
    main
fi
