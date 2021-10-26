#!/bin/bash
oc project ${CP4BANAMESPACE}

# export LBU=`echo ${LDAP_BIND_USERNAME} | base64`
# export LBP=`echo ${LDAP_BIND_PASSWORD} | base64`

oc delete secret ldap-bind-secret
# oc create secret generic ldap-bind-secret --from-literal=ldapUsername="${LBU}" --from-literal=ldapPassword="${LBP}"
oc create secret generic ldap-bind-secret --from-literal=ldapUsername="${LDAP_BIND_USERNAME}" --from-literal=ldapPassword="${LDAP_BIND_PASSWORD}"
