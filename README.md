# Laravel + Docker Quick Setup

This is an automated installer script to quickly set up a Laravel project using Docker (Laradock) with support for Swagger, Redis, MySQL, custom packages, and pre/post install hooks.

---

## 🧰 Features

- Laravel installation or clone from a Git repository
- Laradock with `nginx`, `php-fpm`, `mysql`, `redis`, `phpmyadmin`, `swagger-ui`, `swagger-editor`
- .env auto-configuration for Laravel
- OpenAPI Swagger UI integration (via Laradock)
- Auto-create MySQL database
- Auto-install Laravel packages
- Run pre/post install commands

---

## 🚀 How to Use

### 1. Clone or copy this repo

```bash
git clone <this-repo> my-project
cd my-project
