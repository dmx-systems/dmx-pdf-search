#!/bin/bash

## This tests the tesseract based search result 
## on a previously uploaded PDF.
## Some vars are imported via environment.
##
## jpn 20231223

sleep 1

#URL='access-control/user/workspace'
#WSID="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" -H "Accept: application/json" "${HOST}/${URL}" | jq .id )"
#if [ -z "${WSID}" ]; then
#    echo "ERROR! Empty WSID. Upload aborted."
#    exit 1
#fi

## search for text snipped 'facsimile' in OCR infused index
if [ -f ./uploaded_files.tmp ]; then
    UPLOADED_FILES="$( cat ./uploaded_files.tmp )"
    #echo "<${UPLOADED_FILES}>"
else
    echo "WARNING! File ./uploaded_files.tmp not found."
fi

#PDF='scansmpl.pdf'
#SEARCHTERM='facsimile'

declare -a PDF_SEARCHTERMS="('scansmpl.pdf:facsimile' 'true_PDF.pdf:LibreOfiice')"


for pdfsearch in "${PDF_SEARCHTERMS[@]}"; do
    PDF="$( echo "${pdfsearch}" | cut -d':' -f1 )"
    SEARCHTERM="$( echo "${pdfsearch}" | cut -d':' -f2 )"
    URL="core/topics/query/${SEARCHTERM}"
    HITS=""
    U_ID="$( echo "${UPLOADED_FILES}" | grep "${PDF}" | cut -d':' -f2 )"
    U_NAME="$( echo "${UPLOADED_FILES}" | grep "${PDF}" | cut -d':' -f2 )"
    count=0
    while [ -z "${HITS}" ] && [ ${count} -lt 100 ]; do
        sleep 1
        SEARCH_RESULT="$( curl -sS -H "Cookie: JSESSIONID=${SESSIONID}" "${HOST}/${URL}" )"
        HITS="$( echo "${SEARCH_RESULT}" | jq -c .topics[] )"
        count=$(( ${count} + 1 ))
    done
    ## NOTE: do not try to replace the filename with ${PDF} unless you really know how to do it. 
    if [ "${PDF}" == 'scansmpl.pdf' ]; then
        ID="$( echo "${SEARCH_RESULT}" | jq '.topics[] | select((.value | contains("scansmpl.pdf")) and (.typeUri == "dmx.files.file"))'.id)"
    elif [ "${PDF}" == 'true_PDF.pdf' ]; then
        ID="$( echo "${SEARCH_RESULT}" | jq '.topics[] | select((.value | contains("true_PDF.pdf")) and (.typeUri == "dmx.files.file"))'.id)"
    fi
    if [ "${ID}" != "${U_ID}" ]; then
        echo "ERROR! Search term '${SEARCHTERM}' not found. (HITS=${HITS}, U_ID=${U_ID})"
        exit 1
    else
        echo "INFO: Search for '${SEARCHTERM}' successful. (id=${ID})"
    fi
done

## EOF

