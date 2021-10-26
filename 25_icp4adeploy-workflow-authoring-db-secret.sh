#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret icp4adeploy-workflow-authoring-db-secret
oc create secret generic icp4adeploy-workflow-authoring-db-secret \
--from-literal=dbUser="${WORKFLOWAUTHORINGDBUSERNAME}" \
--from-literal=password="${WORKFLOWAUTHORINGDBPASSWORD}" \
--from-literal=oidcClientPassword="${WORKFLOWAUTHORINGOIDCLIENTPASSWORD}" \
--from-literal=sslKeyPassword="${WORKFLOWAUTHORINGSSLKEYPASSWORD}"
