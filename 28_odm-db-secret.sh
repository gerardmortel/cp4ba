#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret odm-db-secret
oc create secret generic odm-db-secret --from-literal=db-user="${ODMDBUSER}" --from-literal=db-password="${ODMDBPASSWORD}"
