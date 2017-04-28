#!/usr/bin/env bash

set -e

[[ -n "${KC_VERSION}" ]] || { echo "KC_VERSION required, eg. export KC_VERSION=2.5.5.Final"; exit 1; }

KC_DIR="keycloak-${KC_VERSION}"

./${KC_DIR}/bin/jboss-cli.sh -c "shutdown"
