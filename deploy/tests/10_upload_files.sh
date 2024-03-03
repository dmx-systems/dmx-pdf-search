#!/bin/bash

## This teast uploads an image based PDF and 
## then tests the tesseract based search result.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 1

if [ -z "$1" ]; then
    FILE_LIST="$( find deploy/tests/*.pdf -type f )"
else
    FILE_LIST="$1"
fi

declare -a FILES=("${FILE_LIST}")

## get WSID of user's private workspace
URL='access-control/user/workspace'
WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id | sed 's/[^0-9]//g' )"
if [ -z "${WSID}" ]; then
    echo "ERROR! Empty WSID. Upload aborted."
    exit 1
else
    echo "INFO: Uploading files to administrator's Private Workspace ID=${WSID}. (SESSIONID=${SESSIONID})"
fi
URL="upload/%2Fworkspace-${WSID}"
for this_file in ${FILES[@]}; do
    if [ -f ${pdf} ]; then
        echo "INFO: Upload ${this_file} to ${HOST}/${URL}"
        UPLOADED="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -F "data=@${this_file}" "${HOST}/${URL}" 2>&1 )"
        if [ "$( echo "${UPLOADED}" | grep -i ERROR | grep 500 )" ]; then
            echo "ERROR! Upload failed for ${this_file}."
            echo -e "DEBUG:\n${UPLOADED}"
            exit 1
        else
            UPLOADED="$( echo "${UPLOADED}" | jq . )"
        fi
        U_NAME="$( echo "${UPLOADED}" | jq .fileName )"
        U_ID="$( echo "${UPLOADED}" | jq .topicId )"
        filename="$( basename ${this_file} )"
        quoted_filename='"'${filename}'"'
        ## The double quotes are important for '"scansmpl.pdf"'
    else
        echo "ERROR! File ${this_file} not found."
        exit 1
    fi
    if [ "${U_NAME}" != "${quoted_filename}" ]; then
        echo "ERROR! File upload for ${filename} failed."
        echo -e "DEBUG:\n${UPLOADED}"
        exit 1
    else
        ## persist results
        echo "${U_NAME}:${U_ID}" >> uploaded_files.tmp
        echo "INFO: File upload for ${U_NAME} succesful. (id=${U_ID})"
    fi
done

## EOF

