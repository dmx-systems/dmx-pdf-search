#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result

sleep 1

echo "SESSIONID=${SESSIONID}"
echo "HOST=${HOST}"

URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
else
    echo "WSID=${WSID}"
fi
PDF='deploy/tests/scansmpl.pdf'
URL="upload/%2Fworkspace-${WSID}"
echo "POST ${HOST}/${URL}"
## mind "Accept" header!
#curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" -d "data=@${PDF}" "${HOST}/${URL}"
sleep 1
UPLOADED_FILENAME="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${PDF}" "${HOST}/${URL}" | jq .filename )"
echo "UPLOADED_FILENAME=${UPLOADED_FILENAME}"
