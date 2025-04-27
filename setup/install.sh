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
    "find . -type f -exec chmod 644 {} \;"
    "find . -type d -exec chmod 755 {} \;"
    "chgrp -R www-data storage bootstrap/cache"
    "chmod -R ug+rwx storage bootstrap/cache"
    "chmod -R gu+w storage bootstrap/cache && chmod -R guo+w storage bootstrap/cache"
    "cp -r .env.example .env"
    "rm -rf composer.lock"
    "rm -rf vendor"
    "composer install"
    "composer dump-autoload"
    "php artisan key:generate"
    "php artisan optimize:clear"
    "php artisan migrate --seed"
    "composer dump-autoload"
    "npm install"
    "npm run prod"
)

ADDITIONAL_PACKAGES=(

)

# ─────────────────────────────────────────────────────────────
# Source utility script
# ─────────────────────────────────────────────────────────────
source "$(dirname "$0")/utils.sh"

init
