#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret web-security-secret
oc create secret generic web-security-secret --from-file=webSecurity.xml=xml/webSecurity.xml
