#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-dba-ums-external-tls-secret
oc create secret tls ibm-dba-ums-external-tls-secret --cert ${TLSCERTIFICATE} --key ${TLSKEY}
