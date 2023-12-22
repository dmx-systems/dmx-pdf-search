#!/bin/bash

sleep 1

USERNAME='admin'
PASSWORD="${DMX_ADMIN_PASSWORD}"
if [ -z "${TIER}" ]; then
    export TIER='dev'
fi
if [ -z "${WEB_URL}" ] && [ "${CI_COMMIT_BRANCH}" == "master" -o "${CI_COMMIT_BRANCH}" == "main" ]; then
    WEB_URL="${CI_PROJECT_NAME}-${TIER}.ci.dmx.systems"
elif [ -z "${WEB_URL}" ] && [ "${CI_COMMIT_BRANCH}" != "master" -a "${CI_COMMIT_BRANCH}" == "main" ]; then
    WEB_URL="${CI_COMMIT_REF_SLUG}_${CI_PROJECT_NAME}-${TIER}.ci.dmx.systems"
fi
HOST="https://${WEB_URL}:443"
## Test access to Administration workspace to ensure login as admin was successful.
URL='core/topic/uri/dmx.workspaces.administration'
BASE64="$( echo -n "${USERNAME}:${PASSWORD}" | base64 )"
AUTH="Authorization: Basic ${BASE64}"
#echo "curl -sS -H "${AUTH}" "${HOST}/${URL}" -i 2>&1"
SESSION="$( curl -sS -H "${AUTH}" "${HOST}/${URL}" -i 2>&1 )"
HTTPCODE="$( echo "${SESSION}" | grep HTTP | cut -d' ' -f2 )"
if [ "${HTTPCODE}" != "200" -a "${HTTPCODE}" != "204" ]; then
    echo "ERROR! Login ${USERNAME} at ${HOST} failed! (HTTPCODE=${HTTPCODE})"
    exit 1
else
    SESSIONID="$( echo "${SESSION}" | grep ^Set-Cookie: | cut -d';' -f1 | cut -d'=' -f2 )"
    echo "INFO: Login ${USERNAME} at ${HOST} successful. (SESSIONID=${SESSIONID})"
    export SESSIONID=${SESSIONID}
fi

## EOF