#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-dba-ums-mssql-cert
oc create secret generic ibm-dba-ums-mssql-cert --from-file=tls.crt=${DBTLSCERTIFICATE}
