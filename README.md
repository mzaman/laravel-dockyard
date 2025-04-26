# Laravel Dockerized Environment

This project provides a streamlined Docker-based development environment for Laravel using Docker. It includes setup scripts and handy Docker shortcut commands to simplify local development.

## Prerequisites

- Docker & Docker Compose installed
- Bash shell available
- Git installed
- SSH access if cloning a private repository

## Project Structure

```
├── README.md
├── ARCHITECTURE.md
├── SCRIPTS.md
├── cmd
│   ├── art
│   ├── artisan
│   ├── bash
│   ├── clear
│   ├── composer
│   ├── container
│   ├── down
│   ├── exec
│   ├── rebuild
│   ├── restart
│   ├── stop
│   ├── up
│   ├── workspace
├── Setup
│   ├── docker
│   │   ├── docker-compose.local.yml
│   │   ├── mysql
│   │   │   └── Dockerfile
│   │   ├── nginx
│   │   │   └── sites
│   │   │       └── web.local.conf
│   │   └── workspace
│   │       └── crontab
│   │           └── laradock
│   ├── install.sh
│   ├── swagger
│   │   └── swagger.yaml
│   └── utils.sh
└── Sources
    ├── public
    │   └── index.html
    └── web/app
```

## Getting Started

### 1. Clone the repository:

```bash
git clone git@github.com:mzaman/laravel-boilerplate.git example-app
```

### 2. Navigate to the project directory:

```bash
cd insight-cms
```

### 3. Environment Installation
Run the setup script:

```bash
cd Setup
chmod +x install.sh
./install.sh
```

### 4. Edit the `/etc/hosts` file

```bash
sudo nano /etc/hosts
```

Add the following line:
```
127.0.0.1 web.test
```

This `install.sh` script will create a `.env` file with default values and set up the necessary Docker containers.
The installation script will fully automate the setup process, including the configuration of all Docker services, installation of necessary dependencies, Laravel framework setup with specific configurations, database initialization, and seeding of initial data. With this single-step operation, everything will be up and running in just a few minutes. In most cases, you won’t need to manually verify or test any of the setup steps unless there are special circumstances that require attention.

Running the install.sh script multiple times consecutively poses no issues for the proposed project. Each execution will synchronize the necessary setup steps, securely skipping any previously completed processes. It will ensure that the setup progresses from the initial scratch state through the various build stages, ultimately reaching the live application status, even if some parts of the process have already been completed.

And this is the simple installation process — setting everything up effortlessly, so you can get started in no time!


## Docker Shortcut Scripts

| Script     | Description                          | Example Usage                       |
|------------|--------------------------------------|-------------------------------------|
| `workspace`| Enters workspace containers          | `./workspace`                       |
| `up`       | Starts Docker containers             | `./up`                              |
| `stop`     | Stops Docker containers              | `./stop`                            |
| `down`     | Stops and removes containers         | `./down`                            |
| `restart`  | Restarts containers                  | `./restart`                         |
| `rebuild`  | Rebuilds containers with no cache    | `./rebuild`                         |
| `art`      | Runs Laravel Artisan in container    | `./art optimize:clear`              |
| `artisan`  | Runs Laravel Artisan in container    | `./artisan optimize:clear`          |

Make them executable:

```bash
chmod +x cmd/*
```

## Other Example Usages

1. Enter `cmd` directory:

```bash
cd cmd
```

2. Run `./up` to start the containers.

3. Run `./workspace` to enter the workspace container where software is running.

4. Once inside the workspace container, enter `cd /var/www/web` or simply `cd web` to access the Laravel application. You can now run all Composer and Artisan commands.

### Cache Clearing

```bash
./art optimize:clear
```

### Install Composer dependencies

```bash
./composer install
```

### Database Seeding

To populate the database with dummy data, run the following command from the `cmd` directory:

```bash
./art migrate:refresh --seed
```

### Clearing Cached News

```bash
./clear
```

Please see the [Scripts File](SCRIPTS.md) for more information.

**Docker yaml file location:** `Setup/docker/docker-compose.local.yml`

## Output

- Laravel code lives in: `Sources/web`
- Laradock lives in: `Docker/`

**Web URLs:**

- [Web](http://web.test)
- PhpMyAdmin: [http://localhost:8081](http://localhost:8081)
- Host: `mysql`
- Username: `root`
- Password: `root`

**Swagger Test Form:** [http://localhost:5555](http://localhost:5555)

**Swagger source file location:** `Setup/swagger/swagger.yaml`

**Swagger Editor:** [http://localhost:5151](http://localhost:5151)

