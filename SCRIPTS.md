
# Script Usage and Descriptions

### `art`
**Usage**: `./art <command>`  
**Description**: This script is a wrapper for `php artisan`. It allows you to execute any Artisan command inside a Laravel project running within a Docker container. You can run commands like `migrate`, `optimize:clear`, and others using this script.  
**Example**:  
```bash
./art migrate --seed
```
This command runs `php artisan migrate --seed`, which migrates the database and seeds it with data.

Another example:  
```bash
./art optimize:clear
```
This will clear and cache the Laravel configuration, routes, and views.

---

### `artisan`
**Usage**: `./artisan <command>`  
**Description**: This script is another alias for running `php artisan` commands inside a Docker container. It is functionally the same as `./art`, executing any Artisan command inside the Laravel Docker container.  
**Example**:  
```bash
./artisan optimize:clear
```
This command clears cached configuration, routes, and views, improving Laravel's performance.

---

### `bash`
**Usage**: `./bash <container_name> [command]`  
**Description**: This script allows you to run any bash command inside a specified container (e.g., `workspace`). It can execute multiple arguments in the application root inside the container.  
**Examples**:  
```bash
./bash ls -la
./bash composer install
```
This will run `composer install` inside the `workspace` container to install PHP dependencies.

If no command is provided:
```bash
./bash workspace
```
This will open a bash shell inside the `workspace` container, allowing you to run multiple commands interactively.

---

### `clear`
**Usage**: `./clear`  
**Description**: This script is used to run `php artisan optimize:clear` inside the Docker container. It clears all application caches, including configuration, routes, and views. No additional arguments are needed.  
**Example**:  
```bash
./clear
```
This runs `php artisan optimize:clear`, clearing all application caches in the container. As a result, it will rebuild the configuration cache, config cache, route cache, and view cache for below operations.

---

### `composer`
**Usage**: `./composer <command>`  
**Description**: This script runs Composer commands inside the Docker container's `workspace` environment. It can execute all Composer commands like `composer install`, `composer update`, and others.  
**Example**:  
```bash
./composer install
```
This command runs `composer install` inside the Docker container to install PHP dependencies.

Another example:  
```bash
./composer update
```
This command runs `composer update` to update the PHP dependencies.

---

### `container`
**Usage**: `./container <container_name> [command]`  
**Description**: This script allows you to enter a specified Docker container. If no command is provided, it simply enters the container. If a command is provided as the second argument, it will execute it inside the specified container.  
**Example**:  
```bash
./container workspace
```
This will enter the `workspace` container and leave you with an interactive shell.

---

### `exec`
**Usage**: `./exec <container_name> [command]`  
**Description**: This script allows you to enter the specified container and run any command within it. It supports multiple arguments after the container name.  
**Example**:  
```bash
./exec nginx
```
This will enter the `nginx` container and leave you with an interactive shell.

Another example:  
```bash
./exec nginx nginx -t
```
This runs `nginx -t` inside the `nginx` container to test the Nginx configuration.

---

### `down`
**Usage**: `./down`  
**Description**: This script stops and removes Docker containers using `docker-compose down`. It is useful to gracefully shut down the environment and clean up resources.  
**Example**:  
```bash
./down
```
This command stops and removes all containers, networks, and volumes created by `docker-compose`.

---

### `rebuild`
**Usage**: `./rebuild`  
**Description**: This script rebuilds the Docker containers using `docker-compose up --build`. It is typically used when you make changes to the Dockerfiles or application dependencies.  
**Example**:  
```bash
./rebuild
```
This command rebuilds and restarts the Docker containers with the latest changes.

---

### `restart`
**Usage**: `./restart`  
**Description**: This script restarts the Docker containers using `docker-compose restart`. It is used when you need to restart containers without fully bringing them down.  
**Example**:  
```bash
./restart
```
This restarts all the containers defined in `docker-compose.yml`.

---

### `stop`
**Usage**: `./stop`  
**Description**: This script stops the running Docker containers using `docker-compose stop`. It halts the containers without removing them, allowing you to resume work later.  
**Example**:  
```bash
./stop
```
This stops all the running containers without removing them.

---

### `up`
**Usage**: `./up`  
**Description**: This script starts or restarts the Docker containers by running `docker-compose up`. It is used to bring up all the containers defined in `docker-compose.yml`.  
**Example**:  
```bash
./up
```
This command starts or restarts all the containers, including `workspace` and other services defined in the `docker-compose.yml` file.

---

### Summary Table:

| Script      | Description                                                                                      | Example Usage                                        |
|-------------|--------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `art`       | Executes Artisan commands inside the container.                                                  | `./art migrate --seed`                               |
| `artisan`   | Executes Artisan commands inside the container.                                                  | `./artisan optimize:clear`                           |
| `bash`      | Runs bash commands or opens a bash shell inside the container.                                    | `./bash composer install`                            |
| `clear`     | Runs `php artisan optimize:clear` to clear application caches inside the container.               | `./clear`                                            |
| `composer`  | Executes Composer commands inside the container (e.g., `install`, `update`).                      | `./composer install`                                 |
| `container` | Enters a Docker container and runs an optional command inside it.                                 | `./container workspace`                              |
| `exec`      | Enters a Docker container and executes a specified command inside it.                             | `./exec workspace php artisan migrate`               |
| `down`      | Stops and removes the Docker containers using `docker-compose down`.                             | `./down`                                             |
| `rebuild`   | Rebuilds the Docker containers using `docker-compose up --build`.                                 | `./rebuild`                                          |
| `restart`   | Restarts the Docker containers using `docker-compose restart`.                                   | `./restart`                                          |
| `stop`      | Stops the Docker containers using `docker-compose stop`.                                         | `./stop`                                             |
| `up`        | Starts or restarts the Docker containers using `docker-compose up`.                              | `./up`                                               |

---
