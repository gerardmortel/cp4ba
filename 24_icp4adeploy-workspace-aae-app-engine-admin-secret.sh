#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret icp4adeploy-workspace-aae-app-engine-admin-secret
# oc create secret generic icp4adeploy-workspace-aae-app-engine-admin-secret --from-literal=AE_DATABASE_PWD="${AEDBUSERNAME}" --from-literal=AE_DATABASE_USER="${AEDBPASSWORD}" --from-literal=REDIS_PASSWORD="${AEREDISPASSWORD}"

oc create secret generic icp4adeploy-workspace-aae-app-engine-admin-secret \
--from-literal=AE_DATABASE_PWD="${AEDBPASSWORD}" \
--from-literal=AE_DATABASE_USER="${AEDBUSERNAME}" 
# --from-literal=FUNCTION_ADMIN_USER="${AEFUNCTIONADMINUSER}" \
# --from-literal=FUNCTION_ADMIN_PWD="${AEFUNCTIONADMINPWD}" \
# --from-literal=OPENID_CLIENT_ID="${AEOPENIDCLIENTID}" \
# --from-literal=OPENID_CLIENT_SECRET="${AEOPENIDCLIENTSECRET}"
