#!/bin/bash

# ─────────────────────────────────────────────────────────────
# Load all configuration variables
# Uses default if not provided in env or runtime
# ─────────────────────────────────────────────────────────────
load_variables() {
    # Directory references
    LOCAL_SCRIPT_PATH_HOST=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    LOCAL_DOCKER_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Docker"
    LOCAL_APP_CODE_ROOT_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Sources"
    APP_CODE_RELATIVE_PATH="${APP_CODE_RELATIVE_PATH:-$DEFAULT_APP_CODE_RELATIVE_PATH}"
    LOCAL_APP_CODE_PATH_HOST="$LOCAL_APP_CODE_ROOT_PATH_HOST/$APP_CODE_RELATIVE_PATH"
    APP_CODE_PATH_CONTAINER="${APP_CODE_PATH_CONTAINER:-/var/www}"

    # DB settings
    DB_ROOT_USER="${DB_ROOT_USER:-$DEFAULT_DB_ROOT_USER}"
    DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-$DEFAULT_DB_ROOT_PASSWORD}"
    DB_NAME="${DB_NAME:-$DEFAULT_DB_NAME}"

    # Laravel version
    LARAVEL_VERSION="${LARAVEL_VERSION:-$DEFAULT_LARAVEL_VERSION}"

    # Docker services to run
    DOCKER_SERVICES=("${DOCKER_SERVICES[@]:-${DEFAULT_DOCKER_SERVICES[@]}}")
}

# ─────────────────────────────────────────────────────────────
# Allow install.sh to override variables by sourcing this
# ─────────────────────────────────────────────────────────────
override_variables() {
    load_variables
}

# ─────────────────────────────────────────────────────────────
# Pretty output
# ─────────────────────────────────────────────────────────────
print_style() {
    local message=$1
    local color=$2
    case "$color" in
        info) echo -e "\033[0;34m${message}\033[0m" ;;
        success) echo -e "\033[0;32m${message}\033[0m" ;;
        warning) echo -e "\033[0;33m${message}\033[0m" ;;
        danger) echo -e "\033[0;31m${message}\033[0m" ;;
        *) echo -e "${message}" ;;
    esac
}

# ─────────────────────────────────────────────────────────────
# Clone Laradock if not already cloned
# ─────────────────────────────────────────────────────────────
clone_laradock() {
    print_style "📦 Cloning Laradock..." "info"
    if [ ! -d "$LOCAL_DOCKER_PATH_HOST" ]; then
        git clone --branch "$LARADOCK_BRANCH" "$LARADOCK_REPO" "$LOCAL_DOCKER_PATH_HOST"
        rm -rf "$LOCAL_DOCKER_PATH_HOST/.git"
    else
        rm -rf "$LOCAL_DOCKER_PATH_HOST/.git"
        print_style "ℹ️ Laradock already exists. Skipping clone." "warning"
    fi
}

# ─────────────────────────────────────────────────────────────
# Copy any local docker configuration (nginx, crontab, etc.)
# ─────────────────────────────────────────────────────────────
copy_custom_configs() {
    print_style "🛠 Copying custom docker configurations..." "info"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/mysql/Dockerfile" "$LOCAL_DOCKER_PATH_HOST/mysql/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/nginx/sites/"* "$LOCAL_DOCKER_PATH_HOST/nginx/sites/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/workspace/crontab/laradock" "$LOCAL_DOCKER_PATH_HOST/workspace/crontab/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/.env.local.example" "$LOCAL_DOCKER_PATH_HOST/.env"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/docker-compose.local.yml" "$LOCAL_DOCKER_PATH_HOST/docker-compose.yml"
}


# ─────────────────────────────────────────────────────────────
# Execute in local docker container
# ─────────────────────────────────────────────────────────────
execute_in_local_docker() {
    (cd $LOCAL_DOCKER_PATH_HOST && docker-compose exec workspace sh -c "$1")
    if [ $? -ne 0 ]; then
        print_style "Error executing: $1\n" "danger"
        # exit 1
    fi
}

# ─────────────────────────────────────────────────────────────
# Install Laravel using composer (create-project)
# ─────────────────────────────────────────────────────────────
install_laravel() {
    print_style "🧱 Installing Laravel ($LARAVEL_VERSION)..." "info"
    mkdir -p "$LOCAL_APP_CODE_PATH_HOST"
    if [ -f "$LOCAL_APP_CODE_PATH_HOST/artisan" ]; then
        print_style "ℹ️ Laravel already installed. Skipping." "warning"
    else
      execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER && composer create-project --prefer-dist laravel/laravel=\"$LARAVEL_VERSION\" $APP_CODE_RELATIVE_PATH"
    fi
}

# ─────────────────────────────────────────────────────────────
# Start /restart Docker services defined in DOCKER_SERVICES array
# ─────────────────────────────────────────────────────────────
restart_docker_services() {
    print_style "🚀 Starting Docker services: ${DOCKER_SERVICES[*]}" "info"
    (cd "$LOCAL_DOCKER_PATH_HOST" && docker-compose stop && docker-compose up -d "${DOCKER_SERVICES[@]}")
}


# ─────────────────────────────────────────────────────────────
# Create MySQL database inside running container
# ─────────────────────────────────────────────────────────────
create_mysql_database() {
    print_style "🗃 Creating database '$DB_NAME'..." "info"
    docker-compose -f "$LOCAL_DOCKER_PATH_HOST/docker-compose.yml" exec -T mysql \
        mysql -u"$DB_ROOT_USER" -p"$DB_ROOT_PASSWORD" -e \
        "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
}

# ─────────────────────────────────────────────────────────────
# Update Laravel .env to match current MySQL & Redis configs
# ─────────────────────────────────────────────────────────────
configure_laravel_env() {
    print_style "⚙ Configuring Laravel .env file..." "info"

    local ENV_FILE="$LOCAL_APP_CODE_PATH_HOST/.env"
    [ ! -f "$ENV_FILE" ] && cp "$LOCAL_APP_CODE_PATH_HOST/.env.example" "$ENV_FILE"

    # MySQL configuration
    sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" "$ENV_FILE"
    sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_ROOT_USER/" "$ENV_FILE"
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_ROOT_PASSWORD/" "$ENV_FILE"
    sed -i "s/^DB_HOST=.*/DB_HOST=mysql/" "$ENV_FILE"

    # Redis configuration
    sed -i "s/^REDIS_HOST=.*/REDIS_HOST=redis/" "$ENV_FILE"
    sed -i "s/^REDIS_PORT=.*/REDIS_PORT=6379/" "$ENV_FILE"
}
