#!/bin/bash
oc project ${CP4BANAMESPACE}

podname=$(oc get pod | grep ibm-cp4a-operator | awk '{print $1}')
oc cp jdbc ${CP4BANAMESPACE}/$podname:/opt/ansible/share
