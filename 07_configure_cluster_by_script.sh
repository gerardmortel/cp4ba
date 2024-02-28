#!/bin/bash

echo "#### Configure the cluster by script"

echo "#### Logout as user and in as cluster admin"
oc logout
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}
oc project ${CP4BANAMESPACE}

echo "#### Copy yq to ${HOME}/bin"
cp -f ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/helper/yq/yq_linux_amd64 ${HOME}/bin/yq

echo "#### Change to the cert-kubernetes/scripts directory"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts

if [ ${IS_FIRST_CLOUDPAK_IN_CLUSTER} == "false"  ]; then
  echo "#### This is not the first cloudpak in the cluster. The response needs an extra Yes to confirm installation"
  #### cp4ba1 namespace
./cp4a-clusteradmin-setup.sh <<END
2
2
No
Yes
${CP4BANAMESPACE}
2
Yes
2
Yes
${API_KEY_GENERATED}
END
else
  echo "#### This is the first cloudpak in the cluster.  The response does not need an extra Yes to confirm installation"
  ./cp4a-clusteradmin-setup.sh <<END
2
2
No
Yes
${CP4BANAMESPACE}
2
Yes
${API_KEY_GENERATED}
END

# [INFO] Setting up the cluster for IBM Cloud Pak for Business Automation

# Select the cloud platform to deploy: 
# 1) RedHat OpenShift Kubernetes Service (ROKS) - Public Cloud
# 2) Openshift Container Platform (OCP) - Private Cloud
# 3) Other ( Certified Kubernetes Cloud Platform / CNCF)
# Enter a valid option [1 to 3]: 2

# What type of deployment is being performed?
# ATTENTION: The BAI standalone only supports "Production" deployment type.
# 1) Starter
# 2) Production
# Enter a valid option [1 to 2]: 2

# [NOTES] If you are planning to enable FIPS for CP4BA deployment, this script can perform a check on the OCP cluster to ensure the compute nodes have FIPS enabled.
# Do you want to proceed with this check? (Yes/No, default: No): No

# [NOTES] You can install the CP4BA deployment as either a private catalog (namespace scope) or the global catalog namespace (GCN). The private option uses the same target namespace of the CP4BA deployment, the GCN uses the openshift-marketplace namespace.
# Do you want to deploy CP4BA using private catalog? (Yes/No, default: No): Yes

# Where do you want to deploy Cloud Pak for Business Automation?
# Enter the name for a new project or an existing project (namespace): cp4ba

# This script prepares the OLM for the deployment of some Cloud Pak for Business Automation capabilities 

# Here are the existing users on this cluster: 
# 1) Cluster Admin
# 2) gerard
# Enter an existing username in your cluster, valid option [1 to 2], non-admin is suggested: 2

# [INFO] Creating cp4ba-fips-status configMap in the project "cp4ba"

# [✔] Created cp4ba-fips-status configMap in the project "cp4ba".

# Follow the instructions on how to get your Entitlement Key: 
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/23.0.2?topic=deployment-getting-access-images-from-public-entitled-registry

# Do you have a Cloud Pak for Business Automation Entitlement Registry key (Yes/No, default: No): Yes

# Enter your Entitlement Registry key: 
# Verifying the Entitlement Registry key...
# Login Succeeded!
# Entitlement Registry key is valid.

# The existing storage classes in the cluster: 
# NAME                            PROVISIONER        RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# nfs-managed-storage (default)   cp4ba/nfs-client   Delete          Immediate           false                  102m
# Creating docker-registry secret for Entitlement Registry key in project cp4ba...
# secret/ibm-entitlement-key created
# Done

# [INFO] Applying the latest IBM CP4BA Operator catalog source...

# [✔] IBM CP4BA Operator catalog source Updated!

# [INFO] Starting to install IBM Cert Manager and IBM Licensing Operator ...


fi