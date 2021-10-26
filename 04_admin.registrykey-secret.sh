#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret admin.registrykey
oc create secret docker-registry admin.registrykey \
--docker-server=cp.icr.io \
--docker-username=cp \
--docker-password="${API_KEY_GENERATED}" \
--docker-email=${USER_EMAIL}
