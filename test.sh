#!/usr/bin/env bash

set -eu

# Cleanup

rm -rf *.json

# Get tokens with offline_access scope

curl -s \
     -d "client_id=curl" \
     -d "username=user1" \
     -d "password=test123"\
     -d "grant_type=password" \
     -d "scope=offline_access"\
     http://localhost:8080/auth/realms/introspection/protocol/openid-connect/token > initial-tokens.json

OFFLINE_TOKEN=$(cat initial-tokens.json | jq .refresh_token | sed 's/"//g')

# Get a token using the newly obtained offline token
# This will bump the SSO idle timer

curl -s \
     -d "client_id=curl" \
     -d "grant_type=refresh_token" \
     -d "refresh_token=${OFFLINE_TOKEN}" \
     http://localhost:8080/auth/realms/introspection/protocol/openid-connect/token > refreshed-tokens.json

ACCESS_TOKEN=$(cat refreshed-tokens.json | jq .access_token | sed 's/"//g')

# Introspect access_token

curl -s \
     -d "client_id=validator" \
     -d "client_secret=dd3214ca-eb0a-49ea-94ad-3761f575b11b" \
     -d "token=${ACCESS_TOKEN}" \
     -d "token_type_hint=access_token" \
     http://localhost:8080/auth/realms/introspection/protocol/openid-connect/token/introspect > introspect-1.json


STATUS=$(cat introspect-1.json | jq .active)

echo "Token active: ${STATUS}" # active = true -> OK

# Wait 125s as is the Max SSO Idle (2 min) to invalidate the offline session
echo "Waiting to session invalidation 125s..."
sleep 125

# Get a new access_token using the stored offline token

curl -s \
     -d "client_id=curl" \
     -d "grant_type=refresh_token" \
     -d "refresh_token=${OFFLINE_TOKEN}" \
     http://localhost:8080/auth/realms/introspection/protocol/openid-connect/token > refreshed-tokens-2.json

ACCESS_TOKEN_2=$(cat refreshed-tokens-2.json | jq .access_token | sed 's/"//g')


# Introspect the new access_token

curl -s \
     -d "client_id=validator" \
     -d "client_secret=dd3214ca-eb0a-49ea-94ad-3761f575b11b" \
     -d "token=${ACCESS_TOKEN}" \
     -d "token_type_hint=access_token" \
     http://localhost:8080/auth/realms/introspection/protocol/openid-connect/token/introspect > introspect-2.json


STATUS_2=$(cat introspect-2.json | jq .active)

echo "Token active: ${STATUS_2}" # active = false  -> KO
