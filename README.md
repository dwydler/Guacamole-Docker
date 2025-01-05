# Apache Guacamole

## Overview
Apache Guacamole is a clientless remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH.
We call it clientless because no plugins or client software are required.
Thanks to HTML5, once Guacamole is installed on a server, all you need to access your desktops is a web browser.


## Requirements
* Docker & Docker Compose V2
* SSH/Terminal access (able to install commands/functions if non-existent)


## Install Docker, download containers und configure application
1. This script will install docker and containerd:
  ```
  curl https://raw.githubusercontent.com/dwydler/Guacamole-Docker/refs/heads/main/misc/02-docker.io-installation.sh | bash
  ```
2. For IPv6 support, edit the Docker daemon configuration file, located at `/etc/docker/daemon.json`. Configure the following parameters and run `systemctl restart docker.service` to restart docker:
  ```
  {
    "experimental": true,
    "ip6tables": true
  }
  ```
3. Clone the repository to the correct folder for docker container:
  ```
  git clone https://github.com/dwydler/Guacamole-Docker.git /opt/containers/guacamole
  git -C /opt/containers/guacamole checkout $(git -C /opt/containers/guacamole tag | tail -1)
  ```
4. Create the .env file with random passwords:
  ```
  /bin/bash /opt/containers/guacamole/misc/05-setup-apache-guacamole.sh
  ```
5. Editing `/opt/containers/guacamole/.env` and set your parameters and data. Any change requires an restart of the containers.
6. Starting application with `docker compose -f /opt/containers/guacamole/docker-compose.yml up -d`.
7. Don't forget to test, that the application works successfully (e.g. http(s)://FQDN/).


## Updating the stack
Below are the various sections for the different components.

### Update Postgres within the minor version
The following script performs an update of Postgres within a major version branch (e.g. 15.0 to 15.10). Possible manual changes are queried in the script routine.

1. Running follow helper script:
  ```
  /bin/bash /opt/containers/guacamole/misc/25-postgres_update-to-a-new-minor-version.sh
  ```
2. Don't forget to test, that the application works successfully (e.g. http(s)://FQDN/).


### Update Postgres to the major version
The following script updates Postgres from a major version branch (e.g. 15.0 to 17.2). Possible manual changes are queried in the script routine.

1. Running follow helper script:
  ```
  /bin/bash /opt/containers/guacamole/misc/26-postgres_update-to-a-new-major-version.sh
  ```
2. Don't forget to test, that the application works successfully (e.g. http(s)://FQDN/).


### Update the application files via git
1. When you're ready to update the code, you can checkout the latest tag:
  ```
   ( cd /opt/containers/guacamole/ && git fetch && git checkout $(git tag | tail -1) )
  ```
2. No restart needed. The changes will take effect immediately.


## Misc

### Add custom certificate to Java KeyStore
Those who implement user management of Apache Guacamole via LDAPS or SAML usually use certificates from their own root CA. Since Apache Guacamole is based on Java, it comes with its own certificate store. Specifically, this is the file `/opt/java/openjdk/jre/lib/security/cacerts`.

1. Store the root CA certificate in the directory `/opt/containers/guacamole/guacamole/certificates/<name of the ca>.crt` in Base64 format.
2. If you haven't already done so, start the container `docker compose -f /opt/containers/guacamole/docker-compose.yml up -d`.
3. Then execute the following commands:
```
docker exec -u root -it guacamole_frontend bash /__cacert_entrypoint.sh
docker cp guacamole_frontend:/opt/java/openjdk/jre/lib/security/ /opt/containers/guacamole/guacamole/java/
```
4. Open the file `/opt/containers/guacamole/docker-compose.yml` in an editor. Remove the # from the line `#- "./guacamole/java/security:/opt/java/openjdk/jre/lib/security:rw"`. This is to ensure that after a docker compose down && docker compose up -d the original cacert file is not made available again. Otherwise point 3 would have to be repeated again.
5. Stopping application with `docker compose -f /opt/containers/guacamole/docker-compose.yml down`.
6. Starting application with `docker compose -f /opt/containers/guacamole/docker-compose.yml up -d`.


### Create a backup of all Prostgres databases
This script creates a backup of all databases deployed in Postgres. The prerequisite for this is that the Postres container is started. The backup file is saved under `/opt/containers/guacamole/postgres/backup` with the current timestamp.
```
/bin/bash /opt/containers/guacamole/misc/20-postgres-create-backup-all-dbs.sh
```