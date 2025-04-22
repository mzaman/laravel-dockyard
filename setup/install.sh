#!/bin/bash

# install.sh — Main script to install Docker & Laravel environment
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
DEFAULT_DB_ROOT_USER="root"
DEFAULT_DB_ROOT_PASSWORD="root"
DEFAULT_DB_NAME="cms_db"
DEFAULT_APP_CODE_RELATIVE_PATH="web"
DEFAULT_LARAVEL_VERSION="^10"
DEFAULT_DOCKER_SERVICES=(nginx php-fpm php-worker mysql phpmyadmin redis)
LARADOCK_REPO="https://github.com/laradock/laradock.git"
LARADOCK_BRANCH="master"

# ─────────────────────────────────────────────────────────────
# Source utility script
# ─────────────────────────────────────────────────────────────
source "$(dirname "$0")/utils.sh"

# ─────────────────────────────────────────────────────────────
# Main entrypoint
# ─────────────────────────────────────────────────────────────
main() {
    override_variables
    clone_laradock
    copy_custom_configs
    restart_docker_services
    install_laravel
    create_mysql_database
    configure_laravel_env
    print_style "✅ Laravel + Docker setup completed successfully!" "success"
}

main
