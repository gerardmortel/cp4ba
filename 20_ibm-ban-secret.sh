#!/bin/bash

oc project "${CP4BANAMESPACE}"
oc delete secret ibm-ban-secret
oc create secret generic ibm-ban-secret \
  --from-literal=navigatorDBUsername="${NAVIGATORDBUSERNAME}" \
  --from-literal=navigatorDBPassword="${NAVIGATORDBPASSWORD}" \
  --from-literal=keystorePassword="${NAVIGATORKEYSTOREPASSWORD}" \
  --from-literal=ltpaPassword="${NAVIGATORLTPAPASSWORD}" \
  --from-literal=appLoginUsername="${NAVIGATORAPPLOGINUSERNAME}" \
  --from-literal=appLoginPassword="${NAVIGATORAPPLOGINPASSWORD}" \
  --from-literal=jMailUsername="${NAVIGATORJMAILUSERNAME}" \
 --from-literal=jMailPassword="${NAVIGATORJMAILPASSWORD}" \
 -n "${CP4BANAMESPACE}"
