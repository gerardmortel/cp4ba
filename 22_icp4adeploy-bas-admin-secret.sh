#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret icp4adeploy-bas-admin-secret
oc create secret generic icp4adeploy-bas-admin-secret \
--from-literal=dbUsername="${BASDBUSERNAME}" \
--from-literal=dbPassword="${BASDBPASSWORD}"

oc delete secret workflow-bas-admin-secret
oc create secret generic workflow-bas-admin-secret \
--from-literal=dbUsername="${BASDBUSERNAME}" \
--from-literal=dbPassword="${BASDBPASSWORD}"
