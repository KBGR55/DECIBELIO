#!/bin/bash
docker-compose --env-file .docker-env -f docker-compose-dev.yml up --remove-orphans