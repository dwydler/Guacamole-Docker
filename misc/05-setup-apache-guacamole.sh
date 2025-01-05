
#!/bin/bash

######
# Reading out the application directory
APPPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APPPATH="${APPPATH%/*}"
FILE=.env

echo "Check if the file .env already exist.";
if [ ! -f $APPPATH/$FILE ]; then
    echo "File $FILE was created successfully.";
    /bin/cp $APPPATH/.env.example $APPPATH/$FILE

    COPIEDFILES=$((COPIEDFILES + 1))
else
    echo "File $FILE already exist.";
fi

echo
######

if [[ "$COPIEDFILES" -eq "1" ]]; then
    echo "Set random password for the postgres user guacamole.";
    password=$(/bin/tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | /bin/head -c 20)
    /bin/sed -i 's/<your-guacamole-password>/'$password'/g' /$APPPATH/$FILE
fi

echo
######

# Read the major version from the .env file
FILE=docker-compose.yml

echo "Check if the file docker-compose.yml already exist.";
if [ ! -f $APPPATH/$FILE ]; then
    echo "File $FILE was created successfully.";
    /bin/cp $APPPATH/docker-compose.yml.example $APPPATH/$FILE

    COPIEDFILES=$((COPIEDFILES + 1))
else
    echo "File $FILE already exist.";
fi

echo
######


# Read the major version from the .env file
FILEPATH="postgres/init"
FILE="initdb.sql"

# Read the current used version for apache guacamole
GUACAMOLE_VERSION=$(sed -n '/^GUACAMOLE_DOCKER_CONTAINER_TAG=/ {s///p;q;}' "$APPPATH/.env" | cut -d "\"" -f 2)

#
mkdir -p "/$APPPATH/$FILEPATH/"

#
if [ ! -f $APPPATH/$FILEPATH/$FILE ]; then
    echo "File $FILE extracted from container.";
    docker run --rm guacamole/guacamole:$GUACAMOLE_VERSION /opt/guacamole/bin/initdb.sh --postgresql > "/$APPPATH/$FILEPATH/$FILE"

else
    echo "File $FILE already exist.";
fi

