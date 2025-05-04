#!/bin/bash

# utils.sh — Sourced by install.sh for reusable functions

# ─────────────────────────────────────────────────────────────
# Load all configuration variables
# ─────────────────────────────────────────────────────────────
load_variables() {
    LOCAL_SCRIPT_PATH_HOST=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    LOCAL_DOCKER_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Docker"
    LOCAL_APP_CODE_ROOT_PATH_HOST="$LOCAL_SCRIPT_PATH_HOST/../Sources"
    APP_CODE_RELATIVE_PATH="${APP_CODE_RELATIVE_PATH:-$DEFAULT_APP_CODE_RELATIVE_PATH}"
    LOCAL_APP_CODE_PATH_HOST="$LOCAL_APP_CODE_ROOT_PATH_HOST/$APP_CODE_RELATIVE_PATH"
    APP_CODE_PATH_CONTAINER="${APP_CODE_PATH_CONTAINER:-/var/www}"

    DB_ROOT_USER="${DB_ROOT_USER:-$DEFAULT_DB_ROOT_USER}"
    DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-$DEFAULT_DB_ROOT_PASSWORD}"
    DB_NAME="${DB_NAME:-$DEFAULT_DB_NAME}"
    LARAVEL_VERSION="${LARAVEL_VERSION:-$DEFAULT_LARAVEL_VERSION}"
    DOCKER_SERVICES=("${DOCKER_SERVICES[@]:-${DEFAULT_DOCKER_SERVICES[@]}}")

    LARADOCK_REPO="git@github.com:mzaman/laradock.git"
    LARADOCK_BRANCH="master"

    PRE_INSTALL_LARAVEL_COMMANDS=(
        "find . -type f -exec chmod 644 {} \;"
        "find . -type d -exec chmod 755 {} \;"
        "chgrp -R www-data storage bootstrap/cache"
        "chmod -R ug+rwx storage bootstrap/cache"
        "chmod -R gu+w storage bootstrap/cache && chmod -R guo+w storage bootstrap/cache"
    )

    POST_INSTALL_LARAVEL_COMMANDS=(
        "rm -rf composer.lock"
        "rm -rf vendor node_modules"
        "composer install"
        "composer dump-autoload"
        "php artisan key:generate"
        "php artisan optimize:clear"
        "php artisan storage:link"
        "npm install"
        "npm run prod"
    )
}

init() {
    override_variables
    clone_laradock
    copy_custom_configs
    restart_docker_services
    create_database_if_not_exists
    # create_mysql_database
    run_initial_commands

    if [ -n "$REPOSITORY_URL" ]; then
        clone_custom_project
        configure_laravel_env
    else
        clone_fresh_laravel
        configure_laravel_env
    fi

    run_pre_install_laravel_commands
    run_post_install_laravel_commands
    install_additional_packages
    run_post_update_commands

    print_style "✅ Laravel + Docker setup completed successfully!" "success"
}

override_variables() {
    load_variables
}

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

clone_laradock() {
    print_style "📦 Cloning Laradock..." "info"
    if [ ! -d "$LOCAL_DOCKER_PATH_HOST" ]; then
        git clone --branch "$LARADOCK_BRANCH" "$LARADOCK_REPO" "$LOCAL_DOCKER_PATH_HOST"
        rm -rf "$LOCAL_DOCKER_PATH_HOST/.git"
    else
        print_style "ℹ️ Laradock already exists. Skipping clone." "warning"
    fi
}

copy_custom_configs() {
    print_style "🛠 Copying custom docker configurations..." "info"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/mysql/Dockerfile" "$LOCAL_DOCKER_PATH_HOST/mysql/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/nginx/sites/"* "$LOCAL_DOCKER_PATH_HOST/nginx/sites/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/workspace/crontab/laradock" "$LOCAL_DOCKER_PATH_HOST/workspace/crontab/"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/.env.local.example" "$LOCAL_DOCKER_PATH_HOST/.env"
    cp -r "$LOCAL_SCRIPT_PATH_HOST/docker/docker-compose.local.yml" "$LOCAL_DOCKER_PATH_HOST/docker-compose.yml"
    # cp -r "$LOCAL_APP_CODE_PATH_HOST/.env.example" "$LOCAL_APP_CODE_PATH_HOST/.env"
    # cp -r "$LOCAL_SCRIPT_PATH_HOST/swagger/swagger.yaml" "$LOCAL_APP_CODE_PATH_HOST/storage/app/public/swagger.yaml"
}

execute_in_local_docker() {
    (cd "$LOCAL_DOCKER_PATH_HOST" && docker-compose exec workspace sh -c "$1")
    if [ $? -ne 0 ]; then
        print_style "Error executing: $1\n" "danger"
    fi
}

clone_fresh_laravel() {
    print_style "🧱 Installing Laravel ($LARAVEL_VERSION)..." "info"
    mkdir -p "$LOCAL_APP_CODE_PATH_HOST"
    if [ -f "$LOCAL_APP_CODE_PATH_HOST/artisan" ]; then
        print_style "ℹ️ Laravel already installed. Skipping." "warning"
    else
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER && composer create-project --prefer-dist laravel/laravel=\"$LARAVEL_VERSION\" $APP_CODE_RELATIVE_PATH"

    fi
}

run_initial_commands() {
    for cmd in "${INITIAL_COMMANDS[@]}"; do
        print_style "⚙ Running pre-install command: $cmd" "info"
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && $cmd"
    done
}

run_post_update_commands() {
    for cmd in "${POST_UPDATE_COMMANDS[@]}"; do
        print_style "⚙ Running post-install command: $cmd" "info"
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && $cmd"
    done
}

run_pre_install_laravel_commands() {
    for cmd in "${PRE_INSTALL_LARAVEL_COMMANDS[@]}"; do
        print_style "⚙ Running pre-install command: $cmd" "info"
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && $cmd"
    done
}

run_post_install_laravel_commands() {
    for cmd in "${POST_INSTALL_LARAVEL_COMMANDS[@]}"; do
        print_style "⚙ Running post-install command: $cmd" "info"
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && $cmd"
    done
}

clone_custom_project() {
    print_style "🔗 Cloning custom repo: $REPOSITORY_URL" "info"
    git clone  --branch "$REPOSITORY_BRANCH" "$REPOSITORY_URL" "$LOCAL_APP_CODE_PATH_HOST"
    rm -rf "$LOCAL_APP_CODE_PATH_HOST/.git"
}

install_additional_packages() {
    print_style "📦 Installing additional Laravel packages..." "info"
    for package in "${ADDITIONAL_PACKAGES[@]}"; do
        execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && composer require $package --no-interaction"
    done
}

restart_docker_services() {
    print_style "🚀 Starting Docker services: ${DOCKER_SERVICES[*]}" "info"
    (cd "$LOCAL_DOCKER_PATH_HOST" && docker-compose stop && docker-compose up -d "${DOCKER_SERVICES[@]}")
}

create_mysql_database() {
    print_style "🗃 Creating database '$DB_NAME'..." "info"
    docker-compose -f "$LOCAL_DOCKER_PATH_HOST/docker-compose.yml" exec -T mysql \
        mysql -u"$DB_ROOT_USER" -p"$DB_ROOT_PASSWORD" -e \
        "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
}

# Function to create a database and user if they do not exist based on type
create_database_if_not_exists() {
    local DB_TYPE="mysql"
    local DB_USER=$DB_ROOT_USER
    local DB_PASSWORD=$DB_ROOT_PASSWORD
    
    print_style "Checking if database $DB_NAME exists...\n" "info"
    case "$DB_TYPE" in
        mysql)
            local DB_EXISTENCE_CHECK=$(execute_in_mysql_docker "SHOW DATABASES LIKE '$DB_NAME';")
            if echo "$DB_EXISTENCE_CHECK" | grep -q "$DB_NAME"; then
                print_style "Database $DB_NAME already exists.\n" "info"
            else
                print_style "Database $DB_NAME does not exist. Creating database...\n" "info"
                execute_in_mysql_docker "CREATE DATABASE $DB_NAME;"
                if [ $? -eq 0 ]; then
                    print_style "Database $DB_NAME created successfully.\n" "success"
                else
                    print_style "Failed to create database $DB_NAME.\n" "danger"
                    # exit 1
                fi
            fi

            # Check if user exists
            print_style "Checking if user $DB_USER exists...\n" "info"
            local USER_EXISTENCE_CHECK=$(execute_in_mysql_docker "SELECT user FROM mysql.user WHERE user = '$DB_USER';")
            if echo "$USER_EXISTENCE_CHECK" | grep -q "$DB_USER"; then
                print_style "User $DB_USER already exists.\n" "info"
                if [ -n "$DB_PASSWORD" ]; then
                    print_style "Updating password for user $DB_USER...\n" "info"
                    execute_in_mysql_docker "ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'; FLUSH PRIVILEGES;"
                    if [ $? -eq 0 ]; then
                        print_style "Password for user $DB_USER updated successfully.\n" "success"
                    else
                        print_style "Failed to update password for user $DB_USER.\n" "danger"
                        # exit 1
                    fi
                fi
            else
                print_style "User $DB_USER does not exist. Creating user...\n" "info"
                execute_in_mysql_docker "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'; FLUSH PRIVILEGES;"
                if [ $? -eq 0 ]; then
                    print_style "User $DB_USER created and granted privileges successfully.\n" "success"
                else
                    print_style "Failed to create user $DB_USER or grant privileges.\n" "danger"
                    # exit 1
                fi
            fi
            ;;
        # Add cases for other database types like postgres, sqlite, etc.
        *)
            print_style "Unsupported database type: $DB_TYPE\n" "danger"
            # exit 1
            ;;
    esac
}

# Function to execute MySQL commands in the remote Docker container
execute_in_mysql_docker() {
    local command="$1"
    
    # Retry up to 10 times to check if MySQL is ready
    local attempt=1
    local max_attempts=3
    while ! docker-compose -f $LOCAL_DOCKER_PATH_HOST/docker-compose.yml exec -T mysql sh -c "mysql -u$DB_ROOT_USER -p$DB_ROOT_PASSWORD -e \"$command\"" 2>/dev/null; do
        if [ $attempt -ge $max_attempts ]; then
            echo "❌ MySQL connection failed after $max_attempts attempts. Please check your credentials or MySQL container status."
            return 1
        fi
        echo "⏳ Waiting for MySQL to be ready... Attempt $attempt of $max_attempts"
        sleep 3
        ((attempt++))
    done
    return 0
}

configure_laravel_env() {
    print_style "⚙ Configuring Laravel .env file..." "info"
    local ENV_FILE="$LOCAL_APP_CODE_PATH_HOST/.env"
    local EXAMPLE_FILE="$LOCAL_APP_CODE_PATH_HOST/.env.example"

    [ ! -f "$ENV_FILE" ] && cp "$EXAMPLE_FILE" "$ENV_FILE"

    sed -i '' "s|^DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" "$ENV_FILE"
    sed -i '' "s|^DB_USERNAME=.*|DB_USERNAME=$DB_ROOT_USER|" "$ENV_FILE"
    sed -i '' "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_ROOT_PASSWORD|" "$ENV_FILE"
    sed -i '' "s|^DB_HOST=.*|DB_HOST=mysql|" "$ENV_FILE"
    sed -i '' "s|^REDIS_HOST=.*|REDIS_HOST=redis|" "$ENV_FILE"
    sed -i '' "s|^REDIS_PORT=.*|REDIS_PORT=6379|" "$ENV_FILE"

    print_style "🔐 Generating application key..." "info"
    execute_in_local_docker "cd $APP_CODE_PATH_CONTAINER/$APP_CODE_RELATIVE_PATH && php artisan key:generate"
}
