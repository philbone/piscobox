#!/usr/bin/env bash

# --------------------------------------------------
# Pisco Box Global Configuration
# --------------------------------------------------

# Prevent loading the configuration multiple times
# This file is intended to be sourced by provisioning scripts.
if [[ -n "${PISCOBOX_CONFIG_LOADED:-}" ]]; then
  return
fi

readonly PISCOBOX_CONFIG_LOADED=1

# Supported PHP versions for provisioning
readonly PHP_VERSIONS=("8.4" "8.3" "5.6")

# Go configuration
readonly GO_ENABLED=true
readonly GO_VERSION="latest"  # Use "latest" for latest stable, or specify like "1.25.4"
readonly GO_INSTALL_PATH="/usr/local/go"
readonly GO_PATH="/go"