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
REPOSITORY_URL="git@github.com:mzaman/laravel-boilerplate.git"
REPOSITORY_BRANCH="master"
DEFAULT_APP_CODE_RELATIVE_PATH="web"
DEFAULT_DOCKER_SERVICES=(workspace nginx php-fpm php-worker mysql phpmyadmin redis swagger-ui swagger-editor)
DEFAULT_DB_ROOT_USER="root"
DEFAULT_DB_ROOT_PASSWORD="root"
DEFAULT_DB_NAME="laravel_dockyard"
DEFAULT_LARAVEL_VERSION="^9"

INITIAL_COMMANDS=(
    "echo 'No pre-install command'"
)

POST_UPDATE_COMMANDS=(
    "php artisan migrate:refresh --seed"
)

ADDITIONAL_PACKAGES=(

)

# ─────────────────────────────────────────────────────────────
# Source utility script
# ─────────────────────────────────────────────────────────────
source "$(dirname "$0")/utils.sh"

init
