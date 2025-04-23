#!/bin/bash

# install.sh — Main script to install Docker & Laravel environment or clone external project
# Make executable: chmod +x install.sh
# Run: ./install.sh

# Make sure this script is run using Bash
if [ -z "$BASH_VERSION" ]; then
    echo "❌ Please run this script with bash"
    exit 1
fi

# ─────────────────────────────────────────────────────────────
# Default Configuration (can be overridden before running)
# ─────────────────────────────────────────────────────────────
REPOSITORY_URL=""
DEFAULT_APP_CODE_RELATIVE_PATH="web"
DEFAULT_DOCKER_SERVICES=(nginx php-fpm php-worker mysql phpmyadmin redis swagger-ui swagger-editor)
DEFAULT_DB_ROOT_USER="root"
DEFAULT_DB_ROOT_PASSWORD="root"
DEFAULT_DB_NAME="cms_db"
DEFAULT_LARAVEL_VERSION="^10"

INITIAL_COMMANDS=(
    "echo 'No pre-install command'"
)

POST_UPDATE_COMMANDS=(
    "echo 'No post-install command'"
)

ADDITIONAL_PACKAGES=(
    # "barryvdh/laravel-debugbar"
    # "laravel/sanctum"
    # "guzzlehttp/guzzle:^7.0"
    # "spatie/laravel-permission"
)

# ─────────────────────────────────────────────────────────────
# Source utility script
# ─────────────────────────────────────────────────────────────
source "$(dirname "$0")/utils.sh"

init
