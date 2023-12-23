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

## search index for text snipped from OCR ('facsimile')
count=0
HITS=""
while [ -z "${HITS}" ] && [ ${count} -lt 100 ]; do
    sleep 1
    SEARCH_RESULT="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" "https://dmx-pdf-search-dev.ci.dmx.systems:443//core/topics/query/facsimile" )"
    #echo "SEARCH_RESULT=${SEARCH_RESULT}"
    HITS="$( echo "${SEARCH_RESULT}" | jq -c .topics[] )"
    #echo -e "${count} \t HITS=${HITS}"
    count=$(( ${count} + 1 ))
done
ID="$( echo "${SEARCH_RESULT}" | jq '.topics[] | select((.value | contains("scansmpl.pdf")) and (.typeUri == "dmx.files.file"))'.id)"
echo "ID=${ID}"
if [ "${ID}" != "${U_ID}" ]; then
    echo "ERROR! Search term 'facsimile' not found. (HITS=${HITS})"
    exit 1
else
    echo "INFO: Search for 'facsimile' successful. (id=${ID})"
fi

## EOF

