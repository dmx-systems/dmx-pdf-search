#!/bin/bash

echo "SESSIONID=${SESSIONID}"
echo "HOST=${HOST}"

URL='access-control/user/workspace'
WSID="$( curl -I -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
echo "WSID=${WSID}"
PDF='deploy/tests/scansmpl.pdf'
URL="upload/%2Fworkspace-${WSID}"
echo "POST ${HOST}/${URL}"
## mind "Accept" header!
curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" -F "data=@${PDF}" "${HOST}/${URL}"
