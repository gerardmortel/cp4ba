#!/bin/bash

if [ -z ${BANDBCERT} ]
then
  echo "### No Business Automation Navigator certificate specified."
else
  oc project ${CP4BANAMESPACE}
  oc delete secret ${BANDBSECRETNAME}
  oc create secret generic ${BANDBSECRETNAME} --from-file=tls.crt=${BANDBCERT} -n ${CP4BANAMESPACE}
fi
