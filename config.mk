# config.mk - Connect IQ Build Configuration
# This file contains default build settings and SDK autodetection.
# Override settings by creating a properties.mk file (see properties.mk.example).

# Shell configuration for robust Make behavior
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Project file paths (override in properties.mk if needed)
MANIFEST_FILE ?= manifest.xml
JUNGLE_FILE ?= monkey.jungle
SRC_DIR ?= source
RES_DIR ?= resources
BIN_DIR ?= bin
DIST_DIR ?= dist

# SDK Home autodetection (searches multiple common locations)
# Priority order:
#   1. CONNECTIQ_SDK environment variable
#   2. ~/Library/Application Support/Garmin/ConnectIQ/Sdks/ (macOS)
#   3. /Applications/Garmin/ConnectIQ/Sdks/ (macOS)
#   4. ~/connectiq-sdk* (generic)
# If not found, SDK_HOME will be empty and `make validate` will report the issue.
ifndef SDK_HOME
  ifdef CONNECTIQ_SDK
    ifneq ($(wildcard $(CONNECTIQ_SDK)/bin/monkeyc),)
      SDK_HOME := $(CONNECTIQ_SDK)
    endif
  endif
endif

ifndef SDK_HOME
  # Try macOS user library location (most common)
  SDK_SEARCH := $(wildcard $(HOME)/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-*)
  ifneq ($(SDK_SEARCH),)
    SDK_HOME := $(shell find $(HOME)/Library/Application\ Support/Garmin/ConnectIQ/Sdks -maxdepth 1 -type d -name 'connectiq-sdk-*' 2>/dev/null | sort -r | head -n1)
  endif
endif

ifndef SDK_HOME
  # Try macOS applications location
  SDK_SEARCH := $(wildcard /Applications/Garmin/ConnectIQ/Sdks/connectiq-sdk-*)
  ifneq ($(SDK_SEARCH),)
    SDK_HOME := $(shell ls -t /Applications/Garmin/ConnectIQ/Sdks/connectiq-sdk-* 2>/dev/null | head -n1)
  endif
endif

ifndef SDK_HOME
  # Try generic home location
  SDK_SEARCH := $(wildcard $(HOME)/connectiq-sdk*)
  ifneq ($(SDK_SEARCH),)
    SDK_HOME := $(shell ls -t $(HOME)/connectiq-sdk* 2>/dev/null | head -n1)
  endif
endif

# SDK tools (monkeyc compiler and monkeydo simulator runner)
MONKEYC ?= $(SDK_HOME)/bin/monkeyc
MONKEYDO ?= $(SDK_HOME)/bin/monkeydo

# Developer signing key (required for compilation)
# Generate with: openssl genrsa -out .keys/developer_key.pem 4096
#                openssl pkcs8 -topk8 -inform PEM -outform DER \
#                  -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt
PRIVATE_KEY ?= .keys/developer_key.der

# Default target device (override with DEVICE=<device> on command line)
DEFAULT_DEVICE ?= fr265
DEVICE ?= $(DEFAULT_DEVICE)

# Parallel build jobs (auto-detect CPU count)
JOBS ?= $(shell getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Compiler flags
COMMON_FLAGS ?= -w
DEBUG_FLAGS ?= $(COMMON_FLAGS) -g
RELEASE_FLAGS ?= $(COMMON_FLAGS) -r -O3pz
BUILD_MODE ?= debug

# Debug logging (set DEBUG_LOG=1 to enable compiler logging)
ifdef DEBUG_LOG
  DEBUG_FLAGS += --debug-log-level 3 --debug-log-output build-debug.zip
endif

# Select build flags based on BUILD_MODE
ifeq ($(BUILD_MODE),release)
  ACTIVE_FLAGS := $(RELEASE_FLAGS)
else
  ACTIVE_FLAGS := $(DEBUG_FLAGS)
endif

# ANSI color codes for terminal output
C_RESET := \033[0m
C_BOLD := \033[1m
C_RED := \033[31m
C_GREEN := \033[32m
C_YELLOW := \033[33m
C_BLUE := \033[34m
C_MAGENTA := \033[35m
C_CYAN := \033[36m

# App metadata (derived from manifest.xml - do not override unless necessary)
APP_NAME ?= $(notdir $(CURDIR))
