#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-dba-root-ca-cert
oc create secret generic ibm-dba-root-ca-cert --from-file=tls.crt=${ROOTCACERTIFICATE}
