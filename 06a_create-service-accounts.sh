#!/bin/bash

oc project ${CP4BANAMESPACE}
oc apply -f yaml/ibm-cp4ba-anyuid.yaml
oc apply -f yaml/ibm-cp4ba-privileged.yaml

oc adm policy add-scc-to-user privileged -z ibm-cp4ba-privileged -n ${CP4BANAMESPACE}
oc adm policy add-scc-to-user anyuid -z ibm-cp4ba-anyuid -n ${CP4BANAMESPACE}
