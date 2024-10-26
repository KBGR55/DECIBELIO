#!/bin/bash
docker stop decibelio-api-container
docker rm decibelio-api-container
docker rmi decibelio-api:latest

docker stop pgAdmin4-container

docker decibelio-db-container

docker-compose --env-file .docker-env -f docker-compose.yml up -d --remove-orphans