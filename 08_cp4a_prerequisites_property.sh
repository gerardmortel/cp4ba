#!/bin/bash

echo "#### Create property files"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-prerequisites.sh -m property <<END
2

1
2
3

2
${STORAGECLASS}
${STORAGECLASS}
${STORAGECLASS}
${BLOCKSTORAGECLASS}
1
1
dbserver1
${CP4BANAMESPACE}
Yes
END

# 2 Operational Decision Manager
#   Nothing else to add
# 1 Decision Center
# 2 Rule Execution Server
# 3 Decision Runner
#   Nothing else to add
# 2 IBM Secure Directory Server
# ${STORAGECLASS} storage classname for slow storage(RWX)
# ${STORAGECLASS} storage classname for medium storage(RWX)
# ${STORAGECLASS} storage classname for fast storage(RWX)
# ${BLOCKSTORAGECLASS} storage classname for Zen(RWO)
# 1 deployment profile (default: small) 1=small, 2=medium, 3=large
# 1 Database type 1=IBM Db2 Database, 2=Oracle, 3=Microsoft SQL Server, 4=PostgreSQL
# dbserver1 Enter the alias name(s) for the database server(s)/instance(s) to be used by the CP4BA deployment
# ${CP4BANAMESPACE} Enter the name for an existing project (namespace)
# Yes Do you want to restrict network egress to unknown external destination for this CP4BA deployment? (Notes: CP4BA 23.0.2 prevents all network egress to unknown destinations by default. You can either (1) enable all egress or (2) accept the new default and create network policies to allow your specific communication targets as documented in the knowledge center.) (Yes/No, default: Yes)

# ============== Creating database and LDAP property files for CP4BA ==============
# Creating DB Server property file for CP4BA
# [✔] Created the DB Server property file for CP4BA

# Creating LDAP Server property file for CP4BA
# [✔] Created the LDAP Server property file for CP4BA


# ============== Creating property file for database name and user required by CP4BA ==============
# Creating Property file for IBM Business Automation Navigator
# [✔] Created Property file for IBM Business Automation Navigator

# Creating Property file for IBM Operational Decision Manager
# [✔] Created Property file for IBM Operational Decision Manager


# ============== Created all property files for CP4BA ==============
# [NEXT ACTIONS]
# Enter the <Required> values in the property files under /root/cp4ba-23.0.2/ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/cp4ba-prerequisites/propertyfile
# [*] The key name in the property file is created by the cp4a-prerequisites.sh and is NOT EDITABLE.
# [*] The value in the property file must be within double quotes.
# [*] The value for User/Password in [cp4ba_db_name_user.property] [cp4ba_user_profile.property] file should NOT include special characters: single quotation "'"
# [*] The value in [cp4ba_LDAP.property] or [cp4ba_External_LDAP.property] [cp4ba_user_profile.property] file should NOT include special character '"'
# * [cp4ba_db_server.property]:
#   - Properties for database server used by CP4BA deployment, such as DATABASE_SERVERNAME/DATABASE_PORT/DATABASE_SSL_ENABLE.

#   - The value of "<DB_SERVER_LIST>" is an alias for the database servers. The key supports comma-separated lists.

# * [cp4ba_db_name_user.property]:
#   - Properties for database name and user name required by each component of the CP4BA deployment, such as GCD_DB_NAME/GCD_DB_USER_NAME/GCD_DB_USER_PASSWORD.

#   - Change the prefix "<DB_SERVER_NAME>" to assign which database is used by the component.

#   - The value of "<DB_SERVER_NAME>" must match the value of <DB_SERVER_LIST> that is defined in "<DB_SERVER_LIST>" of "cp4ba_db_server.property".

# * [cp4ba_LDAP.property]:
#   - Properties for the LDAP server that is used by the CP4BA deployment, such as LDAP_SERVER/LDAP_PORT/LDAP_BASE_DN/LDAP_BIND_DN/LDAP_BIND_DN_PASSWORD.

# * [cp4ba_user_profile.property]:
#   - Properties for the global value used by the CP4BA deployment, such as "sc_deployment_license".

#   - properties for the value used by each component of CP4BA, such as <APPLOGIN_USER>/<APPLOGIN_PASSWORD>