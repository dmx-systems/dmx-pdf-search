#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 2

URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
fi
PDF='deploy/tests/scansmpl.pdf'
URL="upload/%2Fworkspace-${WSID}"
UPLOADED="$( curl -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${PDF}" "${HOST}/${URL}")"
U_NAME="$( echo "${UPLOADED}" | jq .fileName )"
U_ID="$( echo "${UPLOADED}" | jq .topicId )"
## The double quotes are important for '"scansmpl.pdf"'
if [ "${U_NAME}" != '"scansmpl.pdf"' ]; then
    echo "ERROR! File upload failed."
    echo "DEBUG: ${UPLOADED}"
    exit 1
else
    echo "INFO: PDF upload succesful. (id=${U_ID})"
fi

## EOF

