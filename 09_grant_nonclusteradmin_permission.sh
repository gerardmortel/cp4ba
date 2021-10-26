#!/bin/bash

if [ -z ${NONCLUSTERADMINUSER} ]
then
  echo "Non cluster admin user not specified."
else
  oc project ${CP4BANAMESPACE}

  oc create user ${NONCLUSTERADMINUSER}
  ROLE_NAME_OLM=`oc get role | grep ibm-cp4a-operator | sort -t"t" -k1r | awk 'NR==1{print $1}'`
  oc adm policy add-role-to-user edit ${NONCLUSTERADMINUSER}
  oc adm policy add-role-to-user registry-editor ${NONCLUSTERADMINUSER}
  oc adm policy add-role-to-user ${ROLE_NAME_OLM} ${NONCLUSTERADMINUSER}
fi
