#!/bin/bash

## This tests the tesseract based search result 
## on a previously uploaded PDF.
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

## search for text snipped 'facsimile' in OCR infused index
count=0
PDF='scansmpl.pdf'
SEARCHTERM='facsimile'
URL="core/topics/query/${SEARCHTERM}"
HITS=""
while [ -z "${HITS}" ] && [ ${count} -lt 100 ]; do
    sleep 1
    SEARCH_RESULT="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" "${HOST}/${URL}" )"
    HITS="$( echo "${SEARCH_RESULT}" | jq -c .topics[] )"
    count=$(( ${count} + 1 ))
done
## NOTE: do not replace the filename with ${PDF}
ID="$( echo "${SEARCH_RESULT}" | jq '.topics[] | select((.value | contains("scansmpl.pfd")) and (.typeUri == "dmx.files.file"))'.id)"
if [ "${ID}" != "${U_ID}" ]; then
    echo "ERROR! Search term '${SEARCHTERM}' not found. (HITS=${HITS})"
    exit 1
else
    echo "INFO: Search for '${SEARCHTERM}' successful. (id=${ID})"
fi

## EOF

