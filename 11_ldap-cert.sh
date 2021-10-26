#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ldap-cert
oc create secret generic ldap-cert --from-file=tls.crt=${LDAPCERTIFICATE}
