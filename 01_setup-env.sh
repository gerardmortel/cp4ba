#!/bin/bash

### OpenShift Cluster 4.6 or higher
### The host of the image registry must be able to access the OCP cluster, an internal image registry, and the internet. The host must be on a Linux® x86_64 platform with any operating system that the IBM Cloud Pak® CLI and the OCP CLI support.
### Install OpenSSL version 1.11.1 or higher.
### Install Podman
### Install the skopeo CLI version 1.0.0 or higher. For more information, see Installing skopeo from packages.
### Install the oc OCP CLI tool. For more information, see OCP CLI tools.
### Install httpd-tools.
### Install the IBM Cloud Pak® CLI. Install the version of the binary file for your platform. For more information, see https://github.com/IBM/cloud-pak-cli/releases/latest
### Storage class
### Database info, certificates, if SSL enabled and mssql-jdbc-8.2.2.jre8.jar
### LDAP info and certificates if SSL enabled

### OpenShift Cluster info
export CLUSTER_USER="kubeadmin"
# export CLUSTER_USER="cluster-admin"
# export CLUSTER_USER="ocpadmin"
# export CLUSTER_PASS="N2fka-2haDR-dUzmy-pPani" # ROSA EFS
# export CLUSTER_URL="https://api.rosa-efs-test.zxkp.p1.openshiftapps.com:6443" # ROSA EFS
# export CLUSTER_PASS="7kNcJ-op4Fk-iPRMN-L4AGu" # Env 46
# export CLUSTER_URL="https://api.bts46.cp.fyre.ibm.com:6443" # Env 46
export CLUSTER_PASS="UaCDV-TTC3G-JXoAW-6qqb9" # Env 50
export CLUSTER_URL="https://api.bts50.cp.fyre.ibm.com:6443" # Env 50
# export CLUSTER_PASS="CDFR8-FWFz8-roXVI-NrFbj" # Env 52
# export CLUSTER_URL="https://api.bts52.cp.fyre.ibm.com:6443" # Env 52
# export CLUSTER_PASS="h67Zu-yZmYX-mTxxU-mvWxr" # Env 53
# export CLUSTER_URL="https://api.bts53.cp.fyre.ibm.com:6443" # Env 53

### Log in to the OCP cluster as a cluster administrator.
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}
# oc login --token=sha256~t6KrSy16fFZy7-_nxNUSm2oGQonQIu9XdmCG_XTWyFc --server=https://c100-e.us-south.containers.cloud.ibm.com:32039

### Cloud Pak for Business Automation namespace/project
export CP4BANAMESPACE="cp4ba"
export COMMONSERVICESNAMESPACE="ibm-common-services"

### Preparing Storage Option 1, Dynamic Storage using a storage class
### https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=operator-preparing-log-file-storage
### Script will download and extract this file, https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-automation-3.1.3.tgz
export STORAGECLASS="regions" # Regions Storage
# export STORAGECLASS="ocs-storagecluster-cephfs" # OCS Storage
# export STORAGECLASS="ibmc-file-retain-gold" # This gets created from scripts
# export STORAGECLASS="ibmc-file-gold-gid" # This comes with ROKS

# export STORAGECLASS="efs-sc" # EFS Storage
# export STORAGECLASS="nfs-managed-storage" # NFS Storage

### Preparing Storage Class Option 2, Static Storage using PVs and PVCs
### https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=operator-preparing-log-file-storage
# export NFSSERVER="10.17.66.191" # Env 26
export NFSSERVER="10.22.48.152" # Env 53
export NFSSERVEROPERATORPATH="/data/nfsshare/operator"
export NFSSERVERLOGSPATH="/data/nfsshare/logs"

### Setting up the cluster by installing the IBM Operator Catalog
### https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=suc-setting-up-cluster-by-installing-operator-catalog-from-local-registry

### Manually install the Cloud Pak for Business Automation Operator from the Operator Hub in the correct namespace
### No variables needed, just apply 2 yaml files

### Put the database jar file,mssql-jdbc-8.2.2.jre8.jar, in the jdbc directory using the following structure:
# <current direcotry where this script lives>
#    └── jdbc
#         ├── db2
#             ├── db2jcc4.jar
#             └── db2jcc_license_cu.jar
#         ├── oracle
#             └── ojdbc8.jar
#         ├── sqlserver
#             └── mssql-jdbc-8.2.2.jre8.jar
#         ├── postgresql
#             └── postgresql-42.2.9.jar

### Database JAR File(s), do not change the prefix "jdbc/sqlserver"
#export DBJARFILE="jdbc/sqlserver/mssql-jdbc-8.2.2.jre8.jar" # Path to file for MS SQL Server
export DBJARFILE="jdbc/db2/db2jcc4.jar" # Path to file for DB2
export DBLICENSEFILE="jdbc/db2/db2jcc_license_cu.jar" # Path to file for DB2

### If non cluster admin user needs to create a Cloud Pak for Business Automation deployment
export NONCLUSTERADMINUSER="cpadmin"

### Create LDAP bind info secret
export LDAP_BIND_USERNAME="CN=CEAdmin,OU=Shared,OU=Engineering,OU=FileNet,DC=dockerdom,DC=ecm,DC=ibm,DC=com"
export LDAP_BIND_PASSWORD="Genius1"
# export LDAP_BIND_USERNAME="uid=bluadmin,ou=People,dc=blustratus,dc=com"
# export LDAP_BIND_PASSWORD="v08kvRurchWGNNh"
# export LDAP_BIND_USERNAME="cn=bluldap,dc=blustratus,dc=com"
# export LDAP_BIND_PASSWORD="jIvBq0R0hS8H9yZ"

# export LDAP_BASE_DN="dc=blustratus,dc=com"
export LDAP_BASE_DN="DC=dockerdom,DC=ecm,DC=ibm,DC=com"

### Crate the LDAP certificate secret if SSL enabled
export LDAPCERTIFICATE="certs/tls.crt" # Path to cert

### Create the BAW Encryption key
export BAW_ENCRYPTIONKEY="TA8RolnfPEEt15frxh4sW2H7oWP507LaFwvZLfpRm2TO0v3I4DBLSKPUlp0LthYy"

### Single Postgresql password
export POSTGRESQLPASSWORD="y4uEQJr6QJhsZR63pthBeyeKacv2qsyiCYEUrxmSlPLZ60KN1Qq1zWCrOkUVN6sm" # Env 30

### Create the BAW database info secret
export BAW_DB_USERNAME="db2inst1"
export BAW_DB_PASSWORD="cicdtest"
# export BAW_DB_USERNAME="postgres"
# export BAW_DB_PASSWORD=${POSTGRESQLPASSWORD}
# export BAW_DB_PASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export BAW_DB_PASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export BAW_DB_PASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export BAW_DB_PASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export BAW_DB_PASSWORD="bYVSiNWnV4eqcTpgrwcg0GAtZnpi7mbjrvtUuRLYNgEOCCFfmbS8quO3250HL4P2" # Env 25
# export BAW_DB_PASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24

### Create the UMS info secret
export UMSADMINUSER="umsadmin" # DO NOT CHANGE, as of 21.0.1.x must be hard coded as umsadmin
export UMSADMINPASSWORD="password" # DO NOT CHANGE, as of 21.0.1.x must be hard coded as password
export OAUTHDBUSER="db2inst1"
export OAUTHDBPASSWORD="cicdtest"
# export OAUTHDBUSER="postgres"
# export OAUTHDBPASSWORD=${POSTGRESQLPASSWORD}
# export OAUTHDBPASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export OAUTHDBPASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export OAUTHDBPASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export OAUTHDBPASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export OAUTHDBPASSWORD="bYVSiNWnV4eqcTpgrwcg0GAtZnpi7mbjrvtUuRLYNgEOCCFfmbS8quO3250HL4P2" # Env 25
# export OAUTHDBPASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24

export TSDBUSER="db2inst1"
export TSDBPASSWORD="cicdtest"
# export TSDBUSER="postgres"
# export TSDBPASSWORD=${POSTGRESQLPASSWORD}
# export TSDBPASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export TSDBPASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export TSDBPASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export TSDBPASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export TSDBPASSWORD="bYVSiNWnV4eqcTpgrwcg0GAtZnpi7mbjrvtUuRLYNgEOCCFfmbS8quO3250HL4P2" # Env 25
# export TSDBPASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24

#export LTPAPASSWORD="cicdtest"

### Create the UMS certificate secret (Required for PROD or PROD-like environments)
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=services-creating-ums-secrets
export TLSCERTIFICATE="certs/tls.crt" # Path to file
export TLSKEY="certs/tls.key" # Path to file

### Create the Database certificate secret (SQL Server 2019)
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=services-creating-ums-secrets
# Obtain the base-64 encoded X.509 signer certificate of your MS SQL server.
export DBTLSCERTIFICATE="certs/mssql_tls.crt" # Path to file

### Create the Content Manager secret
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=pifcm-creating-secrets-protect-sensitive-filenet-content-manager-configuration-data
export GCDDBUSERNAME="db2inst1"
export GCDDBPASSWORD="cicdtest"
export OSDBUSERNAME="db2inst1"
export OSDBPASSWORD="cicdtest"
export APPLOGINUSERNAME="CEAdmin"
export APPLOGINPASSWORD="Genius1"
export FNCMKEYSTOREPASSWORD="filenet"
export FNCMLTPAPASSWORD="filenet"

### For PROD and PROD-like environments, create the root CA certificate secret.
### For NON-PROD, can allow the operator (or ROOTCA ansible role) to generate the secret with a self-signed root CA (by not specifying one)
### openssl req -new -x509 -keyout ca.key -out ca.crt -days 1825 -sha256
export ROOTCACERTIFICATE="certs/ca.crt" # Path to file

### Security Context Constraints
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=services-preparing-securitycontextconstraints-scc-requirements
# If we run privileged containers, create ibm-es-service-account
export IBMESSERVICEACCOUNT="ibm-es-service-account" # DO NOT CHANGE, FOR INFO PURPOSES ONLY

### To Do: Ask if customizations such as such as custom case widgets and custom case extensions are required
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=services-preparing-your-environment-customizations

### DO THIS ONLY if certificate is different than other DB certificate. Business Automation Navigator database secret
export BANDBCERT="certs/bandb.crt" # Put certifcate in certs directory and name it here. If same cert as LDAP and other DBs, just reuse secret name in CR and make this blank.
export BANDBSECRETNAME="ban-db-cert-secret"

### Business Automation Navigator info
export NAVIGATORDBUSERNAME="db2inst1"
export NAVIGATORDBPASSWORD="cicdtest"
export NAVIGATORKEYSTOREPASSWORD="filenet"
export NAVIGATORLTPAPASSWORD="filent"
export NAVIGATORAPPLOGINUSERNAME="CEAdmin"
export NAVIGATORAPPLOGINPASSWORD="Genius1"
export NAVIGATORJMAILUSERNAME="CEAdmin"
export NAVIGATORJMAILPASSWORD="Genius1"

### Create volumes and folders

### In CR, don't forget to:
# Set baw_configuration[x].admin_secret_name
# Set ums_configuration.admin_secret_name
# If PROD, set ums_configuration.external_tls_*
# If not PROD, you can remove ums_configuration.external_tls_* secrets
# Add the name of the MS SQL certificate to the list of trusted certificates in the custom resource
# e.g.
# shared_configuration:
#   trusted_certificate_list:
#     - ibm-dba-ums-mssql-cert
# And in the datasource configuration enable SSL and specify the hostname that is used in certificate.
# Set fncm_secret_name to ibm-fncm-secret
# Set root_ca_secret.  See https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=pifcm-creating-secrets-protect-sensitive-filenet-content-manager-configuration-data for more details
# If PROD, add root CA certificate secret to the list of trusted certificates in the custom resource
# e.g.
# shared_configuration:
#   trusted_certificate_list:
#     - ibm-dba-ums-mssql-cert
#     - ibm-dba-root-ca-cert
# Set service_account to ibm-es-service-account under elasticsearch_configuration:
# Set BAN DB cert

#### BAS Studio Database Info
export BASDBUSERNAME="db2inst1"
export BASDBPASSWORD="cicdtest"
# export BASDBUSERNAME="basuser"
# export BASDBPASSWORD="Bpmr0cks"
# export BASDBPASSWORD=${POSTGRESQLPASSWORD}
# export BASDBPASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export BASDBPASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export BASDBPASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export BASDBPASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export BASDBPASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24

#### App Engine Database Info
export AEDBUSERNAME="db2inst1"
export AEDBPASSWORD="cicdtest"
# export AEDBUSERNAME="aeuser"
# export AEDBPASSWORD="Bpmr0cks"
# export AEDBPASSWORD=${POSTGRESQLPASSWORD}
# export AEDBPASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export AEDBPASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export AEDBPASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export AEDBPASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export AEDBPASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24
export AEREDISPASSWORD="" # Optional if not using Redis
export AEFUNCTIONADMINUSER="basuser" # Added due to error that FUNCTION_ADMIN_USER not found in secret
export AEFUNCTIONADMINPWD="Bpmr0cks" # Added due to error that FUNCTION_ADMIN_PWD not found in secret
export AEOPENIDCLIENTID="CEAdmin" # Added due to error that OPENID_CLIENT_ID not found in secret
export AEOPENIDCLIENTSECRET="" # Added due to error that OPENID_CLIENT_SECRET not found in secret

#### Worklow Authoring DB Info
export WORKFLOWAUTHORINGOIDCLIENTPASSWORD="Bpmr0cks"
export WORKFLOWAUTHORINGSSLKEYPASSWORD="Bpmr0cks"
export WORKFLOWAUTHORINGDBUSERNAME="db2inst1"
export WORKFLOWAUTHORINGDBPASSWORD="cicdtest"
# export WORKFLOWAUTHORINGDBUSERNAME="wfauser"
# export WORKFLOWAUTHORINGDBPASSWORD="Bpmr0cks"
# export WORKFLOWAUTHORINGDBPASSWORD="${POSTGRESQLPASSWORD}"
# export WORKFLOWAUTHORINGDBPASSWORD="vf295nnevTXliSRPKGs4nzza8YVwzhbeDqI5SaANPIBBTuVIQ6wQHRkVW6se1v4t" # Env 29
# export WORKFLOWAUTHORINGDBPASSWORD="iGQaINRjedhgpTwZYfbHa530Yun7s7Qbc6r6K1LTJuEQRXMR1TZApysRO9eWilAq" # Env 28
# export WORKFLOWAUTHORINGDBPASSWORD="nY2MPhuwYq0TOQtTFqVNcway56xpeduISRkT4PDGNsdm9wfhZOna44Vo5rwuAV5l" # Env 27
# export WORKFLOWAUTHORINGDBPASSWORD="NxnpLpdhYsPp9bqh0NppDoFaD43oCXVkObx92nbrTjKaYCg0CyCCc0Jpal0ZHZu1" # Env 26
# export WORKFLOWAUTHORINGDBPASSWORD="eGKqXBmpTFLQOldky2OGDrTOmxEFs49Qu4fQ9tdrHCnx2dWfMVFVPjS8HI0F10CE" # Env 24

#### ADS
export ADSENCRYPTIONKEY="TA8RolnfPEEt15frxh4sW2H7oWP507LaFwvZLfpRm2TO0v3I4DBLSKPUlp0LthYy"

#### ADP
export ADPSERVICEUSER="CN=CEAdmin,OU=Shared,OU=Engineering,OU=FileNet,DC=dockerdom,DC=ecm,DC=ibm,DC=com"
export ADPSERVICEPASSWORD="Genius1"
export ADPSERVICEUSERBAS="CN=CEAdmin,OU=Shared,OU=Engineering,OU=FileNet,DC=dockerdom,DC=ecm,DC=ibm,DC=com"
export ADPSERVICEPASSWORDBAS="Genius1"
export ADPSERVICEUSERCA="CN=CEAdmin,OU=Shared,OU=Engineering,OU=FileNet,DC=dockerdom,DC=ecm,DC=ibm,DC=com"
export ADPSERVICEPASSWORDCA="Genius1"
export ADPENVOWNERUSER="CN=CEAdmin,OU=Shared,OU=Engineering,OU=FileNet,DC=dockerdom,DC=ecm,DC=ibm,DC=com"
export ADPENVOWNERPASSWORD="Genius1"

export BASE_DB_USER="db2inst1"
export BASE_DB_PWD="cicdtest"
export TENANT1DB_NAME="PROJDB1"
export TENANT1_DB_PWD="cicdtest"
export TENANT2DB_NAME="PROJDB2"
export TENANT2_DB_PWD="cicdtest"

export ODMDBUSER="db2inst1"
export ODMDBPASSWORD="cicdtest"

#### End







































### Create a secret to access the IBM container registry
### Get entitlement key from https://myibm.ibm.com/products-services/containerlibrary
export API_KEY_GENERATED="eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA"
export USER_EMAIL="gmortel@us.ibm.com"
