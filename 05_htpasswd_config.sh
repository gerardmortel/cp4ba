#!/bin/bash

echo "#### Move to a directory where you want to put the temp files."
cd /home

echo "#### Install the htpasswd command."
yum install httpd-tools

echo "#### Create a user."
htpasswd -c -B -b users.htpasswd ${HTPASSWDUSERNAME} ${HTPASSWDPASSWORD}

echo "#### Verify that it worked."
htpasswd -b -v users.htpasswd ${HTPASSWDUSERNAME} ${HTPASSWDPASSWORD}

echo "#### Create a secret to contain the htpasswd file. You must be logged in as the admin user to the cluster."
oc create secret generic htpass-secret \
--from-file=htpasswd=./users.htpasswd \
-n openshift-config

Create a config file with the htpasswd identity provider settings.
cat <<EOF | kubectl apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
 identityProviders:
 - name: admins_htpasswd_provider
   mappingMethod: claim
   type: HTPasswd
   htpasswd:
     fileData:
       name: htpass-secret
EOF

Verify that it worked. It might take a few minutes for the update to complete.
oc logout
oc login -u [username] -p [password]

If you see an Unauthorized error, wait a few minutes more and try to login again.