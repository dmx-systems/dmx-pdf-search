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
UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${PDF}" "${HOST}/${URL}" | jq -c . )"
echo "UPLOADED=${UPLOADED}"
U_NAME="$( echo "${UPLOADED}" | jq -c .fileName )"
U_ID="$( echo "${UPLOADED}" | jq -c .id )"

echo "UPLOADED_FILENAME=${U_NAME}"
## The double quotes are important for '"scansmpl.pdf"'
if [ "${UPLOADED_FILENAME}" != '"scansmpl.pdf"' ]; then
    echo "weird! /o\ "
else
    echo "great! \o/ "
fi
## search index
TOPIC_ID="$( curl -sS -H "Cookie: JSESSIONID=dshc07xw2x2wrwj4j9gzhw1f" "https://dmx-pdf-search-dev.ci.dmx.systems:443//core/topics/query/facsimile" \
    | jq -c '.topics[] | select((.value | contains("scansmpl.pdf")) and (.typeUri == "dmx.files.file"))'.id )"
echo "ID=${TOPIC_ID}"
