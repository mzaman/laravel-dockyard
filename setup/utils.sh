#!/bin/bash

# Ensure the script runs in Bash
if [ -z "$BASH_VERSION" ]; then
    echo "Please run this script with bash"
    exit 1
fi


# Load all required variables
load_variables() {
    # Point to where the `APP_CODE_ROOT_PATH_CONTAINER` should be in the container
    APP_CODE_ROOT_PATH_CONTAINER="/var/www"
    # Point to where the `APP_CODE_ROOT_PATH_HOST` should be in the host
    APP_CODE_ROOT_PATH_HOST="${APP_CODE_ROOT_PATH_HOST:-$APP_CODE_ROOT_PATH_CONTAINER}"

    # Define master credentials of database
    DB_ROOT_USER="${DB_ROOT_USER:-$DEFAULT_DB_ROOT_USER}"
    DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-$DEFAULT_DB_ROOT_PASSWORD}"

    # Define paths
    # Define the local script path
    LOCAL_SCRIPT_PATH_HOST=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    # Point to the path of your docker on your local host
    LOCAL_DOCKER_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Docker"
    # Point to the path of your applications code on your local host
    LOCAL_APP_CODE_ROOT_PATH_HOST="../Sources"
    APP_CODE_RELATIVE_PATH="${APP_CODE_RELATIVE_PATH:-$DEFAULT_APP_CODE_RELATIVE_PATH}"
    LOCAL_APP_CODE_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Sources/$APP_CODE_RELATIVE_PATH"

    # Define the laravel version
    LARAVEL_VERSION="${LARAVEL_VERSION:-$DEFAULT_LARAVEL_VERSION}"
}

# Load default variables
load_variables

# Function to override variables
override_variables() {
    for var in "$@"; do
        eval "$var"
    done
    load_variables  # Reload variables if overrides are provided
}

# Function to print messages with styles
print_style() {
    local message=$1
    local color=$2
    case "$color" in
        info) echo -e "\033[0;33m${message}\033[0m" ;;  # Yellow
        success) echo -e "\033[0;32m${message}\033[0m" ;;  # Green
        warning) echo -e "\033[0;33m${message}\033[0m" ;;  # Yellow
        danger) echo -e "\033[0;31m${message}\033[0m" ;;  # Red
        *) echo -e "${message}" ;;
    esac
}

# Function to execute commands in the local Docker container
execute_in_local_docker() {
    (cd $LOCAL_DOCKER_PATH_HOST && docker-compose exec workspace sh -c "$1")
    if [ $? -ne 0 ]; then
        print_style "Error executing: $1\n" "danger"
        # exit 1
    fi
}