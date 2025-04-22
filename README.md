
# Laravel Dockerized Environment

This repository provides a streamlined way to scaffold a Laravel development environment using Docker and Laradock. It includes an automated `install.sh` script and utility commands to manage containers and services efficiently.

## Directory Structure

```
.
├── README.md                  # Readme file
├── Scripts/                   # Docker shortcut commands
│   ├── artisan                # Run Laravel Artisan commands
│   ├── down                   # Stop and remove containers
│   ├── rebuild                # Rebuild containers
│   └── up                     # Start containers
├── Setup/
│   ├── docker/                # Custom Docker configs
│   │   ├── docker-compose.local.yml
│   │   ├── mysql/
│   │   │   └── Dockerfile
│   │   ├── nginx/
│   │   │   └── sites/web.local.conf
│   │   └── workspace/
│   │       └── crontab/laradock
│   ├── install.sh             # Main setup script
│   └── utils.sh               # Utility functions
├── Sources/                   # Laravel app will be placed here
└── Docker/                    # Laradock cloned here automatically

```

## Requirements

- Docker
- Docker Compose
- Bash

## Quick Start

```bash
chmod +x install.sh
./install.sh
```

## Docker Scripts

Make the scripts executable:

```bash
chmod +x Scripts/*
```

Then run like:

```bash
./Scripts/up
./Scripts/down
./Scripts/rebuild
./Scripts/artisan migrate
```

## 📦 Custom Docker Configs

Custom Docker config files should be placed in the `docker/` directory and will be copied into Laradock.

## 🌍 Access

Visit: http://localhost/
