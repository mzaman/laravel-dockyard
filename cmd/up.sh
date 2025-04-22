#!/bin/bash
docker-compose -f ../Docker/docker-compose.yml up -d nginx php-fpm php-worker mysql phpmyadmin redis swagger-ui swagger-editor