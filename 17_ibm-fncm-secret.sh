#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-fncm-secret
oc create secret generic ibm-fncm-secret \
--from-literal=adposDBUsername="${OSDBUSERNAME}" \
--from-literal=adposDBPassword="${OSDBPASSWORD}" \
--from-literal=gcdDBUsername="${GCDDBUSERNAME}" \
--from-literal=gcdDBPassword="${GCDDBPASSWORD}" \
--from-literal=osDBUsername="${OSDBUSERNAME}" \
--from-literal=osDBPassword="${OSDBPASSWORD}" \
--from-literal=devos1DBUsername="${OSDBUSERNAME}" \
--from-literal=devos1DBPassword="${OSDBPASSWORD}" \
--from-literal=appLoginUsername="${APPLOGINUSERNAME}" \
--from-literal=appLoginPassword="${APPLOGINPASSWORD}" \
--from-literal=keystorePassword="${FNCMKEYSTOREPASSWORD}" \
--from-literal=ltpaPassword="${FNCMLTPAPASSWORD}"
