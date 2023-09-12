#!/bin/bash

# Download the CASE (Container Application Software for Enterprises) package
#curl -L https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-automation/5.0.0/ibm-cp-automation-5.0.0.tgz -o ibm-cp-automation-5.0.0.tgz
curl -L https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-automation/5.0.2/ibm-cp-automation-5.0.2.tgz -o ibm-cp-automation-5.0.2.tgz

# Extract the package
tar -xzvf ibm-cp-automation-5.0.2.tgz

# Extract the cert-k8s-23.0.1.tar file
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs
tar -xvf cert-k8s-23.0.1.tar