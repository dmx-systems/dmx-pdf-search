#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 1

URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
fi
PDF='deploy/tests/scansmpl.pdf'
URL="upload/%2Fworkspace-${WSID}"
#echo "POST ${HOST}/${URL}"
UPLOADED_FILENAME="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${PDF}" "${HOST}/${URL}" )"
echo "UPLOADED_FILENAME=${UPLOADED_FILENAME}"
