#!/bin/bash
oc project ${CP4BANAMESPACE}

export BAWDBU=`echo ${BAW_DB_USERNAME} | base64`
export BAWDBP=`echo ${BAW_DB_PASSWORD} | base64`

oc delete secret ibm-baw-wfs-server-db-secret
oc create secret generic ibm-baw-wfs-server-db-secret \
--from-literal=dbUser="${BAW_DB_USERNAME}" \
--from-literal=password="${BAW_DB_PASSWORD}"

# --from-literal=dbUser="${BAWDBU}" \
# --from-literal=password="${BAWDBP}"
