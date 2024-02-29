#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 1

declare -a PDFS=('deploy/tests/scansmpl.pdf' 'deploy/tests/true_PDF.pdf' 'deploy/tests/tesseract.pdf')

## get WSID of user's private workspace
URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
else
    echo "INFO: Private Workspace ID=${WSID}. (SESSIONID=${SESSIONID})"
fi
URL="upload/%2Fworkspace-${WSID}"
for pdf in ${PDFS[@]}; do
    if [ -f ${pdf} ]; then
        echo "INFO: Upload ${pdf} to ${HOST}/${URL}"
        # UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${pdf}" "${HOST}/${URL}" | jq . )"
        UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${pdf}" "${HOST}/${URL}" )"
        if [ "$( echo "${UPLOADED}" | grep -i ERROR | grep 500 )" ]; then
            echo "ERROR! Upload failed for ${pdf}."
            echo -e "DEBUG:\n${UPLOADED}"
            exit 1
        else
            UPLOADED="$( echo "${UPLOADED}" | jq . )"
        fi
        U_NAME="$( echo "${UPLOADED}" | jq .fileName )"
        U_ID="$( echo "${UPLOADED}" | jq .topicId )"
        filename="$( basename ${pdf} )"
        quoted_filename='"'${filename}'"'
        ## The double quotes are important for '"scansmpl.pdf"'
    else
        echo "ERROR! File ${pdf} not found."
        exit 1
    fi
    if [ "${U_NAME}" != "${quoted_filename}" ]; then
        echo "ERROR! File upload for ${filename} failed."
        echo -e "DEBUG:\n${UPLOADED}"
        exit 1
    else
        ## persist resluts
        echo "${U_NAME}:${U_ID}" >> uploaded_files.tmp
        echo "INFO: File upload for ${U_NAME} succesful. (id=${U_ID})"
    fi
done

## EOF

