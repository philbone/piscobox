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