#!/bin/bash

# Reading out the application directory
APPPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APPPATH="${APPPATH%/*}"
echo $APPPATH

# Read the postgres username from the .env file
POSTGRES_USER=$(sed -n '/^POSTGRES_USER=/ {s///p;q;}' "$APPPATH/.env" | cut -d "\"" -f 2)
echo $POSTGRES_USER


###


# Stops containers and removes containers, networks, volumes, and images created by up
docker compose -f "$APPPATH/docker-compose.yml" down

# Adjust the tag for the postgres container
vi "$APPPATH/.env"

# Starts the specified container and runs in the background
docker compose -f "$APPPATH/docker-compose.yml" up -d postgres

# Run the SQL commands for the three mentioned databases
docker exec -it guacamole_database psql -U $POSTGRES_USER -c "REINDEX DATABASE guacamole;" -c "ALTER DATABASE guacamole REFRESH COLLATION VERSION;"
docker exec -it guacamole_database psql -U $POSTGRES_USER -c "REINDEX DATABASE postgres;"  s-c "ALTER DATABASE postgres REFRESH COLLATION VERSION;"
docker exec -it guacamole_database psql -U $POSTGRES_USER -c "REINDEX DATABASE template1;" -c "ALTER DATABASE template1 REFRESH COLLATION VERSION;"

# Stops the specified container
docker compose -f "$APPPATH/docker-compose.yml" stop postgres

# Builds, (re)creates, starts, and deattaches the specified container
docker compose -f "$APPPATH/docker-compose.yml" up -d

# View output from the specified container
docker compose -f "$APPPATH/docker-compose.yml" logs -f postgres
