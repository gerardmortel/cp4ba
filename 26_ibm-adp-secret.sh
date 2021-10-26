#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-adp-secret
oc create secret generic ibm-adp-secret \
--from-literal=serviceUser="${ADPSERVICEUSER}" \
--from-literal=servicePwd="${ADPSERVICEPASSWORD}" \
--from-literal=serviceUserBas="${ADPSERVICEUSERBAS}" \
--from-literal=servicePwdBas="${ADPSERVICEPASSWORDBAS}" \
--from-literal=serviceUserCa="${ADPSERVICEUSERCA}"  \
--from-literal=servicePwdCa="${ADPSERVICEPASSWORDCA}" \
--from-literal=envOwnerUser="${ADPENVOWNERUSER}" \
--from-literal=envOwnerPwd="${ADPENVOWNERPASSWORD}"
