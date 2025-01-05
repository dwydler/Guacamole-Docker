#!/bin/bash

# Reading out the application directory
APPPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APPPATH="${APPPATH%/*}"
echo $APPPATH

# Read the major version from the .env file
POSTGRES_VERSION=$(sed -n '/^POSTGRES_DOCKER_CONTAINER_TAG_MAJOR_VERSION=/ {s///p;q;}' "$APPPATH/.env" | cut -d "\"" -f 2)
echo $VERSION

# Read the postgres username from the .env file
POSTGRES_USER=$(sed -n '/^POSTGRES_USER=/ {s///p;q;}' "$APPPATH/.env" | cut -d "\"" -f 2)
echo $POSTGRES_USER

# Create a unique file name
FILENAME="postgres${POSTGRES_VERSION}_$(date '+%Y-%m-%d_%H-%M-%S').sql"

# Create the directory "backup" if it does not already exist
mkdir -p "$APPPATH/postgres/backup/"


###


# Stops containers and removes containers, networks, volumes, and images created by up
docker compose -f "$APPPATH/docker-compose.yml" down

# Builds, (re)creates, starts, and deattaches the specified container
docker compose -f "$APPPATH/docker-compose.yml" up -d postgres

# View output from the specified container
docker compose -f "$APPPATH/docker-compose.yml" logs -f postgres

# Create a backup of all postgres databases
docker exec -it guacamole_database pg_dumpall -U $POSTGRES_USER > "$APPPATH/postgres/backup/$FILENAME"

# Stops containers and removes containers, networks, volumes, and images created by up
docker compose -f "$APPPATH/docker-compose.yml" down

# Builds, (re)creates, starts, and deattaches the specified container
docker compose -f "$APPPATH/docker-compose.yml" up -d
