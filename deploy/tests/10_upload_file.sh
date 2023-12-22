#!/bin/bash

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
curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" -F "data=@${PDF}" "${HOST}/${URL}"
