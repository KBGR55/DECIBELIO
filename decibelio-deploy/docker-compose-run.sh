#!/bin/bash

docker stop decibelio-api-container
docker rm decibelio-api-container
docker rmi decibelio-api:latest

#docker stop adminer-db-container
docker stop decibelio-db-container

docker compose --env-file .docker-env -f docker-compose.yml up -d --remove-orphans
