# Testing Keycloak OAuth2 introspection

## Requirements

* Bash
* JDK 8
* [wget](https://www.gnu.org/software/wget/)
* [curl](https://curl.haxx.se/)
* [jq](https://stedolan.github.io/jq/)

## Usage

    export KC_VERSION=3.0.0.Final
    ./setup.sh && ./test.sh && ./tear_down.sh

## Details

* The `keycloak.h2.db` contains an __introspection__ realm

* The realm has a modified settings:
  * 1 minute is the life of an access_token
  * 2 minutes is the _SSO Idle time_

* The `setup.sh` scripts downloads the Keycloak distribution, unpacks it
  and copies the `keycloak.h2.db` to the proper location. Then starts
  Keycloak server in the background, waiting 45secs

* The `test.sh` script, makes token requests using `curl` and processing
  the responses with `jq`
  * Request an offline token using direct grants
  * Use the offline token to obtain an access token and use the introspection
    endpoint to verify it. It works as there is one active offline session.
  * Wait more then 2min to the offline session expires
  * Use the offline token to obtain a new access token
  * Use the introspection endpoint to verify the new access token. This _fails_
    as there is no active session

* The `tear_down.sh` stops the Keycloak server
