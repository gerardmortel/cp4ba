#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-dba-ums-secret

# Make a copy of ibm-dba-ums-secret.yaml and replace the variables
cp -p yaml/ibm-dba-ums-secret.yaml yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<UMSADMINUSER>|$UMSADMINUSER|g" yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<UMSADMINPASSWORD>|$UMSADMINPASSWORD|g" yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<OAUTHDBUSER>|$OAUTHDBUSER|g" yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<OAUTHDBPASSWORD>|$OAUTHDBPASSWORD|g" yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<TSDBUSER>|$TSDBUSER|g" yaml/new-ibm-dba-ums-secret.yaml
sed -ri "s|<TSDBPASSWORD>|$TSDBPASSWORD|g" yaml/new-ibm-dba-ums-secret.yaml
#sed -ri "s|<LTPAPASSWORD>|$LTPAPASSWORD|g" yaml/new-ibm-dba-ums-secret.yaml


oc apply -f yaml/new-ibm-dba-ums-secret.yaml
