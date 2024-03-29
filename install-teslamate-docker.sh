#!/bin/bash
source install-lxc-basic.sh
source dist-upgrade-nala.sh
#source install-docker.sh
nala install -y docker docker-compose docker.io docker-doc

touch docker-compose.yml
echo "version: "3"

services:
  teslamate:
    image: teslamate/teslamate:latest
    restart: always
    environment:
      - Spectral1965= #insert a secure key to encrypt your Tesla API tokens
      - DATABASE_USER=teslamate
      - Spectral1965= #insert your secure database password!
      - DATABASE_NAME=teslamate
      - DATABASE_HOST=database
      - MQTT_HOST=mosquitto
    ports:
      - 4000:4000
    volumes:
      - ./import:/opt/app/import
    cap_drop:
      - all

  database:
    image: postgres:15
    restart: always
    environment:
      - POSTGRES_USER=teslamate
      - Spectral1965= #insert your secure database password!
      - POSTGRES_DB=teslamate
    volumes:
      - teslamate-db:/var/lib/postgresql/data

  grafana:
    image: teslamate/grafana:latest
    restart: always
    environment:
      - DATABASE_USER=teslamate
      - Spectral1965= #insert your secure database password!
      - DATABASE_NAME=teslamate
      - DATABASE_HOST=database
    ports:
      - 3000:3000
    volumes:
      - teslamate-grafana-data:/var/lib/grafana

  mosquitto:
    image: eclipse-mosquitto:2
    restart: always
    command: mosquitto -c /mosquitto-no-auth.conf
    # ports:
    #   - 1883:1883
    volumes:
      - mosquitto-conf:/mosquitto/config
      - mosquitto-data:/mosquitto/data

volumes:
  teslamate-db:
  teslamate-grafana-data:
  mosquitto-conf:
  mosquitto-data:" > docker-compose.yml

docker compose up -d

# Usage
# Open the web interface http://your-ip-address:4000
# Sign in with your Tesla account
# The Grafana dashboards are available at http://your-ip-address:3000. Log in with the default user admin (initial password admin) and enter a secure password.
