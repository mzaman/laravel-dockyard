#!/bin/bash

# This shell script is an optional tool to simplify
# Installing docker and then running application in local server.
#
# To run, make sure to add permissions to this file:
# chmod 755 ./install.sh

# USAGE EXAMPLE:
# Executing docker: ./install.sh

# Default configurations
DEFAULT_DB_ROOT_USER="root"
DEFAULT_DB_ROOT_PASSWORD="root"
DEFAULT_APP_CODE_RELATIVE_PATH="web"
DEFAULT_LARAVEL_VERSION="8.0"

# Ensure the script runs in Bash
if [ -z "$BASH_VERSION" ]; then
    echo "Please run this script with bash"
    exit 1
fi

# Source utilities
source utils.sh
