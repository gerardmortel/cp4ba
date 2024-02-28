# Install IBM Cloud Pak for Business Automation on OpenShift on Fyre
# https://github.com/gerardmortel/cp4ba

# Resources used to create this
IBM Cloud Pak for Business Automation 23.0.1 Knowledge Center
https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/23.0.1

Cloud Pak for Business Automation Interim fix download document
https://www.ibm.com/support/pages/node/6576423#r23.0.1

IBM/cloud-pak-cli
https://github.com/IBM/cloud-pak-cli

# Purpose
The purpose of this repo is to install the IBM Cloud Pak for Business Automation (CP4BA) on OpenShift on Fyre on OpenShift on Fyre.

# Prerequisites
1. OpenShift 4.10+ cluster on Fyre
2. NFS Storage configured https://github.com/gerardmortel/nfs-storage-for-fyre
3. Entitlement key https://myibm.ibm.com/products-services/containerlibrary
4. kubectl 1.21+
5. ocp cli
6. podman

# Instructions
1. ssh into the infrastructure node as root (e.g. ssh root@api.slavers.cp.fyre.ibm.com)
2. yum install -y git unzip podman
3. cd
4. rm -rf cp4ba-23.0.1
5. rm -f 23.0.1.zip
6. curl -L https://github.com/gerardmortel/cp4ba/archive/refs/heads/23.0.1.zip -o 23.0.1.zip
7. unzip 23.0.1.zip
8. rm -f 23.0.1.zip
9. cd cp4ba-23.0.1
10. STOP! Put your values for ALL VARIABLES inside file 02_setup_env.sh
11. ./01_driver.sh | tee install_cp4ba.log