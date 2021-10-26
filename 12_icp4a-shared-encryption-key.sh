#!/bin/bash
oc project ${CP4BANAMESPACE}

export BEK=`echo ${BAW_ENCRYPTIONKEY} | base64`

oc delete secret icp4a-shared-encryption-key
# oc create secret generic icp4a-shared-encryption-key --from-literal=encryptionKey="${BEK}"
oc create secret generic icp4a-shared-encryption-key --from-literal=encryptionKey="${BAW_ENCRYPTIONKEY}"
