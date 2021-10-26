#!/bin/bash
. ./01_setup-env.sh

#### After creating OCS or NFS storage
#### Before installing DB2 and CP4BA operators or after Postgresql operator and cluster creation
# ./02_create-namespace.sh
# ./03_prepare-operator-log-storage.sh
# ./04_admin.registrykey-secret.sh
# ./05_ibm.registrykey-secret.sh
# ./06_ibm-entitlement-key-secret.sh
# ./06a_create-service-accounts.sh # DEMO
# ./07_install-ibm-operator-catalog.sh
./09_grant_nonclusteradmin_permission.sh
./11_ldap-cert.sh
./12_icp4a-shared-encryption-key.sh
./13_ibm-baw-wfs-server-db-secret.sh
./14_ibm-dba-ums-secret.sh
./15_ibm-dba-ums-external-tls-secret.sh
./16_ibm-dba-ums-mssql-cert.sh
./17_ibm-fncm-secret.sh
./18_ibm-dba-root-ca-cert.sh
./19_ibm-es-service-account.sh
./20_ibm-ban-secret.sh
./21_ibm-ban-db-cert.sh
./22_icp4adeploy-bas-admin-secret.sh
./23_playback-server-admin-secret.sh
./24_icp4adeploy-workspace-aae-app-engine-admin-secret.sh
./25_icp4adeploy-workflow-authoring-db-secret.sh # Workflow Authoring
# ./26_ibm-adp-secret.sh # Automation Document Processing
# ./27_aca-basedb-secret.sh # Content Analyzer
# ./28_odm-db-secret.sh
# ./29_web-security-secret.sh

# Uninstal foundational services
## https://www.ibm.com/docs/en/cloud-paks/1.0?topic=online-uninstalling-foundational-services


#### After Cloud Pak for Business Automation operator install
./08_copy_db_jar.sh
./10_ldap-bind-secret.sh # Placed later in case you use Postgresql and need to put in Postgresql passwords

#### Work in progress
# ./28_resource-registry-admin-secret.sh # To Do: Research how to create this
