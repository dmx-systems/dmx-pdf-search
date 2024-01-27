#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 1

declare -a PDFS=('deploy/tests/scansmpl.pdf' 'deploy/tests/true_PDF.pdf')

URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
fi
URL="upload/%2Fworkspace-${WSID}"
for pfd in ${PDFS[@]}; do
    UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${pdf}" "${HOST}/${URL}" | jq . )"
    U_NAME="$( echo "${UPLOADED}" | jq .fileName )"
    U_ID="$( echo "${UPLOADED}" | jq .topicId )"
    filename="$( basename ${pdf} )"
    quoted_filename='"'${filename}'"'
    ## The double quotes are important for '"scansmpl.pdf"'
    if [ "${U_NAME}" != "${quoted_filename}" ]; then
        echo "ERROR! File upload for ${filename} failed."
        echo "DEBUG: ${UPLOADED}"
        exit 1
    else
        echo "INFO: File upload for ${filename} succesful. (id=${U_ID})"
    fi
fi

## EOF

