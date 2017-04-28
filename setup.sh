#!/usr/bin/env bash

set -e

[[ -n "${KC_VERSION}" ]] || { echo "KC_VERSION required, eg. export KC_VERSION=2.5.5.Final"; exit 1; }

export LAUNCH_JBOSS_IN_BACKGROUND=1

# Get KC distribution

KC_FILENAME="keycloak-${KC_VERSION}.tar.gz"
KC_DIR="keycloak-${KC_VERSION}"

wget --timestamp "https://downloads.jboss.org/keycloak/${KC_VERSION}/${KC_FILENAME}"

echo "Extracting archive..."

tar xfz ${KC_FILENAME}

# Make data folder to put sample data

mkdir -p ${KC_DIR}/standalone/data/

cp -v keycloak.h2.db ${KC_DIR}/standalone/data/

# Start server

./${KC_DIR}/bin/standalone.sh -b 0.0.0.0 2>&1 > keycloak.log &

# Wait for KC to start
echo "Starting Keycloak. Waiting 60s..."
sleep 60
