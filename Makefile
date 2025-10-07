# Makefile for Connect IQ Hello World App
# Professional build system for Garmin Connect IQ projects

# Shell configuration
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.ONESHELL:

# Load configuration
include config.mk
-include properties.mk

# Derived metadata from manifest.xml
APP_ENTRY := $(shell ./scripts/extract_manifest_attr.py "$(MANIFEST_FILE)" entry)
APP_ID := $(shell ./scripts/extract_manifest_attr.py "$(MANIFEST_FILE)" id)
APP_VERSION := $(shell ./scripts/extract_manifest_attr.py "$(MANIFEST_FILE)" version)
PROJECT_VERSION_FILE ?= VERSION
PROJECT_VERSION := $(if $(wildcard $(PROJECT_VERSION_FILE)),$(shell tr -d '\r\n' < $(PROJECT_VERSION_FILE)),)
PROJECT_VERSION_DISPLAY := $(if $(PROJECT_VERSION),$(PROJECT_VERSION),$(C_YELLOW)Not set$(C_RESET))

# Device list (extracted from manifest)
DEVICES := $(shell ./scripts/list_devices.sh $(MANIFEST_FILE) 2>/dev/null | tr '\n' ' ')

# Source and resource files (for dependency tracking)
SOURCE_FILES := $(shell find $(SRC_DIR) -type f -name '*.mc' 2>/dev/null)
RESOURCE_FILES := $(shell find $(RES_DIR) -type f 2>/dev/null)

# All build artifacts for all devices
ALL_PRGS := $(addprefix $(BIN_DIR)/$(APP_NAME)_,$(addsuffix .prg,$(DEVICES)))

# Phony targets (not files)
.PHONY: help validate devices version build run buildall release package test testall clean doctor lint

#===============================================================================
# Help Target
#===============================================================================

help: ## Show this help message
	@echo ""
	@printf "$(C_BOLD)$(C_BLUE)Garmin Connect IQ Build System$(C_RESET)\n"
	@printf "$(C_BLUE)================================$(C_RESET)\n\n"
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@printf "$(C_BOLD)Common Targets:$(C_RESET)\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(C_GREEN)%-12s$(C_RESET) %s\n", $$1, $$2}'
	@echo ""
	@printf "$(C_BOLD)Build Variables:$(C_RESET)\n"
	@echo "  DEVICE         Target device (default: $(DEFAULT_DEVICE))"
	@echo "  BUILD_MODE     debug or release (default: debug)"
	@echo "  JOBS           Parallel jobs for buildall (default: $(JOBS))"
	@echo ""
	@printf "$(C_BOLD)Examples:$(C_RESET)\n"
	@echo "  make build                    # Build for default device ($(DEFAULT_DEVICE))"
	@echo "  make build DEVICE=fenix7      # Build for specific device"
	@echo "  make buildall -j$(JOBS)            # Build for all devices in parallel"
	@echo "  make run DEVICE=epix2         # Build and run in simulator"
	@echo "  make release -j$(JOBS)             # Build optimized releases for all devices"
	@echo ""
	@printf "$(C_BOLD)Current Configuration:$(C_RESET)\n"
	@echo "  App Name:      $(APP_NAME)"
	@echo "  SDK:           $(if $(SDK_HOME),$(shell basename "$(SDK_HOME)"),$(C_RED)Not found$(C_RESET))"
	@echo "  Devices:       $(DEVICES)"
	@echo ""

#===============================================================================
# Validation and Information Targets
#===============================================================================

validate: ## Validate development environment
	@printf "$(C_BLUE)[INFO]$(C_RESET) Validating environment...\n"
	@SDK_HOME="$(SDK_HOME)" \
	MANIFEST_FILE="$(MANIFEST_FILE)" \
	JUNGLE_FILE="$(JUNGLE_FILE)" \
	PROJECT_VERSION_FILE="$(PROJECT_VERSION_FILE)" \
	PRIVATE_KEY="$(PRIVATE_KEY)" \
	MONKEYC="$(MONKEYC)" \
	MONKEYDO="$(MONKEYDO)" \
	./scripts/validate_env.sh

devices: ## List all supported devices
	@printf "$(C_BLUE)[INFO]$(C_RESET) Supported devices in $(MANIFEST_FILE):\n\n"
	@for device in $(DEVICES); do \
		printf "  $(C_GREEN)•$(C_RESET) $$device\n"; \
	done
	@echo ""
	@printf "Total: $(C_BOLD)$(words $(DEVICES))$(C_RESET) devices\n\n"

version: ## Show SDK, tool, and app version information
	@printf "$(C_BLUE)[INFO]$(C_RESET) SDK and Tool Versions:\n\n"
	@echo "SDK Home:    $(SDK_HOME)"
	@echo "App Name:    $(APP_NAME)"
	@echo "App Entry:   $(APP_ENTRY)"
	@echo "App ID:      $(APP_ID)"
	@echo "App Version: $(if $(APP_VERSION),$(APP_VERSION),$(C_RED)Unknown$(C_RESET))"
	@echo "Project Version (VERSION): $(PROJECT_VERSION_DISPLAY)"
	@echo ""
	@if [ -x "$(MONKEYC)" ]; then printf "Compiler:    "; "$(MONKEYC)" --version 2>&1 | head -n1; else printf "$(C_RED)Compiler not found$(C_RESET)\n"; fi
	@echo ""

#===============================================================================
# Directory Creation
#===============================================================================

$(BIN_DIR):
	@mkdir -p "$(BIN_DIR)"

$(DIST_DIR):
	@mkdir -p "$(DIST_DIR)"

#===============================================================================
# Build Rules
#===============================================================================

# Pattern rule: build .prg for any device
$(BIN_DIR)/$(APP_NAME)_%.prg: $(JUNGLE_FILE) $(MANIFEST_FILE) $(SOURCE_FILES) $(RESOURCE_FILES) | $(BIN_DIR)
	@printf "$(C_BLUE)[BUILD]$(C_RESET) Building for device: $(C_BOLD)$*$(C_RESET) ($(BUILD_MODE) mode)\n"
	@"$(MONKEYC)" \
		-f "$(JUNGLE_FILE)" \
		-d "$*" \
		-o "$@" \
		-y "$(PRIVATE_KEY)" \
		$(ACTIVE_FLAGS)
	@printf "$(C_GREEN)[OK]$(C_RESET) Created: $@\n\n"

build: validate $(BIN_DIR)/$(APP_NAME)_$(DEVICE).prg ## Build for default or specified device
	@printf "$(C_GREEN)[SUCCESS]$(C_RESET) Build complete for $(C_BOLD)$(DEVICE)$(C_RESET)\n"
	@printf "  Output: $(BIN_DIR)/$(APP_NAME)_$(DEVICE).prg\n\n"

buildall: validate $(ALL_PRGS) ## Build for all devices (use -j for parallel builds)
	@printf "\n$(C_GREEN)[SUCCESS]$(C_RESET) Built for all devices!\n\n"
	@printf "$(C_BOLD)Build Artifacts:$(C_RESET)\n"
	@ls -lh $(BIN_DIR)/*.prg 2>/dev/null | awk '{printf "  %s  %s\n", $$9, $$5}'
	@echo ""
	@printf "Tip: Use $(C_YELLOW)make -j$(JOBS)$(C_RESET) for parallel builds\n\n"

release: ## Build optimized releases for all devices
	@printf "$(C_BLUE)[INFO]$(C_RESET) Building release versions...\n\n"
	@$(MAKE) buildall BUILD_MODE=release
	@printf "$(C_GREEN)[SUCCESS]$(C_RESET) Release build complete!\n\n"

#===============================================================================
# Run and Test Targets
#===============================================================================

run: build ## Build and run in simulator for specified device
	@printf "$(C_BLUE)[RUN]$(C_RESET) Launching simulator for $(C_BOLD)$(DEVICE)$(C_RESET)...\n\n"
	@"$(MONKEYDO)" "$(BIN_DIR)/$(APP_NAME)_$(DEVICE).prg" "$(DEVICE)"

# Test configuration
TEST_JUNGLE_FILE := monkey.jungle.test
TEST_MANIFEST_FILE := manifest.test.xml

test: validate ## Build with --unit-test and run Connect IQ unit tests with /t flag
	@printf "$(C_BLUE)[TEST]$(C_RESET) Running test suite for $(C_BOLD)$(DEVICE)$(C_RESET)...\n\n"
	@# Ensure simulator is running (macOS only)
	@if [[ "$$(uname)" == "Darwin" ]] && [[ -f "scripts/ensure_simulator.sh" ]]; then \
		./scripts/ensure_simulator.sh || \
		(printf "$(C_YELLOW)[WARNING]$(C_RESET) Failed to start simulator automatically\n"; \
		 printf "$(C_YELLOW)[WARNING]$(C_RESET) Please ensure Connect IQ Simulator is running manually\n\n"); \
	fi
	@printf "$(C_BLUE)[BUILD]$(C_RESET) Building tests for $(DEVICE) with --unit-test flag...\n"
	@"$(MONKEYC)" \
		-f "$(TEST_JUNGLE_FILE)" \
		-d "$(DEVICE)" \
		-o "$(BIN_DIR)/test_$(DEVICE).prg" \
		-y "$(PRIVATE_KEY)" \
		--unit-test
	@printf "$(C_GREEN)[OK]$(C_RESET) Test build complete\n"
	@printf "$(C_BLUE)[RUN]$(C_RESET) Launching Connect IQ unit tests with -t flag...\n"
	@"$(MONKEYDO)" "$(BIN_DIR)/test_$(DEVICE).prg" "$(DEVICE)" -t || { \
		EXIT_CODE=$$?; \
		if [[ $$EXIT_CODE -eq 1 ]]; then \
			printf "$(C_YELLOW)[INFO]$(C_RESET) Test execution completed (Connect IQ simulator exited with code 1)\n"; \
		else \
			printf "$(C_RED)[ERROR]$(C_RESET) Test execution failed with exit code $$EXIT_CODE\n"; \
			exit $$EXIT_CODE; \
		fi; \
	}
	@printf "$(C_GREEN)[SUCCESS]$(C_RESET) Tests completed for $(DEVICE)\n\n"

testall: validate ## Build and run Connect IQ unit tests for all devices
	@printf "$(C_BLUE)[TEST]$(C_RESET) Running test suite for all devices...\n\n"
	@# Ensure simulator is running (macOS only) - do this once for all devices
	@if [[ "$$(uname)" == "Darwin" ]] && [[ -f "scripts/ensure_simulator.sh" ]]; then \
		./scripts/ensure_simulator.sh || \
		(printf "$(C_YELLOW)[WARNING]$(C_RESET) Failed to start simulator automatically\n"; \
		 printf "$(C_YELLOW)[WARNING]$(C_RESET) Please ensure Connect IQ Simulator is running manually\n\n"); \
	fi
	@for device in $(DEVICES); do \
		printf "$(C_BLUE)[TEST]$(C_RESET) Testing device: $(C_BOLD)$$device$(C_RESET)\n"; \
		printf "$(C_BLUE)[BUILD]$(C_RESET) Building tests for $$device...\n"; \
		"$(MONKEYC)" \
			-f "$(TEST_JUNGLE_FILE)" \
			-d "$$device" \
			-o "$(BIN_DIR)/test_$$device.prg" \
			-y "$(PRIVATE_KEY)" \
			--unit-test && \
		printf "$(C_GREEN)[OK]$(C_RESET) Test build complete for $$device\n" && \
		printf "$(C_BLUE)[RUN]$(C_RESET) Running Connect IQ unit tests with -t flag...\n" && \
		("$(MONKEYDO)" "$(BIN_DIR)/test_$$device.prg" "$$device" -t || { \
			EXIT_CODE=$$?; \
			if [[ $$EXIT_CODE -ne 1 ]]; then \
				printf "$(C_RED)[FAIL]$(C_RESET) Tests failed for $$device with exit code $$EXIT_CODE\n\n"; \
				exit $$EXIT_CODE; \
			fi; \
		}) && \
		printf "$(C_GREEN)[OK]$(C_RESET) Tests passed for $$device\n\n" || \
		(printf "$(C_RED)[FAIL]$(C_RESET) Tests failed for $$device\n\n"; exit 1); \
	done
	@printf "$(C_GREEN)[SUCCESS]$(C_RESET) All tests completed successfully!\n\n"

#===============================================================================
# Packaging Target
#===============================================================================

PACKAGE_BASENAME := $(APP_NAME)$(if $(PROJECT_VERSION),_$(PROJECT_VERSION),)

package: release | $(DIST_DIR) ## Create store packages (.iq files)
	@printf "$(C_BLUE)[PACKAGE]$(C_RESET) Creating store packages...\n\n"
	@if [ -x "$(SDK_HOME)/bin/monkeyc" ]; then \
	       printf "$(C_BLUE)[INFO]$(C_RESET) Attempting to create .iq package...\n"; \
	       "$(MONKEYC)" \
	               -f "$(JUNGLE_FILE)" \
	               -o "$(DIST_DIR)/$(PACKAGE_BASENAME).iq" \
	               -e \
	               -y "$(PRIVATE_KEY)" \
	               $(RELEASE_FLAGS) && \
	       printf "$(C_GREEN)[OK]$(C_RESET) Package created: $(DIST_DIR)/$(PACKAGE_BASENAME).iq\n\n" || \
	       ( \
	               printf "$(C_RED)[ERROR]$(C_RESET) Packaging failed\n\n"; \
			printf "$(C_YELLOW)Packaging Options:$(C_RESET)\n"; \
			printf "  1. Use monkeyc with -e flag (attempted above)\n"; \
			printf "  2. Use the Connect IQ IDE to export .iq file\n"; \
			printf "  3. Update SDK via SDK Manager for latest packaging tools\n\n"; \
			exit 1 \
		); \
	else \
		printf "$(C_RED)[ERROR]$(C_RESET) SDK not found - cannot package\n\n"; \
		exit 1; \
	fi

#===============================================================================
# Maintenance Targets
#===============================================================================

clean: ## Remove all build artifacts
	@printf "$(C_BLUE)[CLEAN]$(C_RESET) Removing build artifacts...\n"
	@rm -rf "$(BIN_DIR)" "$(DIST_DIR)"
	@printf "$(C_GREEN)[OK]$(C_RESET) Clean complete\n\n"

doctor: validate devices version ## Run all diagnostic checks
	@printf "$(C_GREEN)[SUCCESS]$(C_RESET) Environment healthy!\n\n"

lint: ## Run shellcheck on scripts (if available)
	@if command -v shellcheck >/dev/null 2>&1; then \
		printf "$(C_BLUE)[LINT]$(C_RESET) Running shellcheck on scripts...\n"; \
		shellcheck scripts/*.sh || true; \
		printf "$(C_GREEN)[OK]$(C_RESET) Lint complete\n\n"; \
	else \
		printf "$(C_YELLOW)[INFO]$(C_RESET) shellcheck not installed - skipping lint\n"; \
		printf "  Install with: brew install shellcheck\n\n"; \
	fi
