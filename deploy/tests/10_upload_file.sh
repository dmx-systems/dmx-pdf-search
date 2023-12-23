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
UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${PDF}" "${HOST}/${URL}" | jq . )"
#echo "UPLOADED=${UPLOADED}"
U_NAME="$( echo "${UPLOADED}" | jq .fileName )"
U_ID="$( echo "${UPLOADED}" | jq .topicId )"

# echo "UPLOADED_FILENAME=${U_NAME}"
## The double quotes are important for '"scansmpl.pdf"'
if [ "${U_NAME}" != '"scansmpl.pdf"' ]; then
    echo "ERROR! File upload failed."
    echo "DEBUG: ${UPLOADED}"
    exit 1
else
    echo "INFO: PDF upload succesful. (id=${U_ID})"
fi
## search index
## DMX and tesseract have a need for sleep here to process the OCR
sleep 3
count=0
HITS=""
while [ -z "${HITS}" ] && [ ${count} -lt 20 ]; do
    SEARCH_RESULT="$( curl -sS -H "Cookie: JSESSIONID=dshc07xw2x2wrwj4j9gzhw1f" "https://dmx-pdf-search-dev.ci.dmx.systems:443//core/topics/query/facsimile" )"
    echo "SEARCH_RESULT=${SEARCH_RESULT}"
    HITS="$( echo "${SEARCH_RESULT}" | jq .topics[] )"
    echo "HITS=${HITS}"
    count=$(( ${count} + 1 ))
    sleep 2
done
ID="$( echo "${SEARCH_RESULT}" | jq '.topics[] | select((.value | contains("scansmpl.pdf")) and (.typeUri == "dmx.files.file"))'.id)"
echo "ID=${ID}"
