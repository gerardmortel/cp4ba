#!/bin/bash

echo "#### Edit property files"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/cp4ba-prerequisites/propertyfile

echo "#### Edit cp4ba_db_name_user.property"
cp -p cp4ba_db_name_user.property cp4ba_db_name_user.property.orig
sed -r "s/USER_NAME=\"<youruser1>\"/USER_NAME=\"${DB_USERNAME}\"/g" cp4ba_db_name_user.property > cp4ba_db_name_user.property.1
sed -r "s/USER_PASSWORD=\"<yourpassword>\"/USER_PASSWORD=\"${DB_PASSWORD}\"/g" cp4ba_db_name_user.property.1 > cp4ba_db_name_user.property.2

echo "#### Copy last file to first file"
rm -f cp4ba_db_name_user.property
cp cp4ba_db_name_user.property.2 cp4ba_db_name_user.property

echo "#### Edit cp4ba_db_server.property"
cp -p cp4ba_db_server.property cp4ba_db_server.property.orig
sed -r "s/SERVERNAME=\"<Required>\"/SERVERNAME=\"${DB_SERVER}\"/g" cp4ba_db_server.property > cp4ba_db_server.property.1
sed -r "s/PORT=\"<Required>\"/PORT=\"${DB_PORT}\"/g" cp4ba_db_server.property.1 > cp4ba_db_server.property.2
sed -r "s/SSL_ENABLE=\"True\"/SSL_ENABLE=\"${DB_SSL}\"/g" cp4ba_db_server.property.2 > cp4ba_db_server.property.3
sed -r "s/SERVERNAME=\"<Optional>\"/SERVERNAME=\"\"/g" cp4ba_db_server.property.3 > cp4ba_db_server.property.4
sed -r "s/PORT=\"<Optional>\"/PORT=\"\"/g" cp4ba_db_server.property.4 > cp4ba_db_server.property.5

echo "#### Copy last file to first file"
rm -f cp4ba_db_server.property
cp cp4ba_db_server.property.5 cp4ba_db_server.property

echo "#### Edit cp4ba_LDAP.property"
cp -p cp4ba_LDAP.property cp4ba_LDAP.property.orig
sed -r "s/LDAP_SERVER=\"<Required>\"/LDAP_SERVER=\"${LDAP_SERVER}\"/g" cp4ba_LDAP.property > cp4ba_LDAP.property.1
sed -r "s/LDAP_PORT=\"<Required>\"/LDAP_PORT=\"${LDAP_PORT}\"|g" cp4ba_LDAP.property.1 > cp4ba_LDAP.property.2
sed -r "s/LDAP_BASE_DN=\"<Required>\"/LDAP_BASE_DN=\"${LDAP_BASE_DN}\"/g" cp4ba_LDAP.property.2 > cp4ba_LDAP.property.3
sed -r "s/LDAP_BIND_DN=\"<Required>\"/LDAP_BIND_DN=\"${LDAP_BIND_DN}\"/g" cp4ba_LDAP.property.3 > cp4ba_LDAP.property.4
sed -r "s/LDAP_BIND_DN_PASSWORD=\"<Required>\"/LDAP_BIND_DN_PASSWORD=\"${LDAP_BIND_DN_PASSWORD}\"/g" cp4ba_LDAP.property.4 > cp4ba_LDAP.property.5
sed -r "s/LDAP_SSL_ENABLED=\"True\"/LDAP_SSL_ENABLED=\"${LDAP_SSL_ENABLED}\"/g" cp4ba_LDAP.property.5 > cp4ba_LDAP.property.6
sed -r 's|LDAP_USER_NAME_ATTRIBUTE="<Required>"|LDAP_USER_NAME_ATTRIBUTE="*:uid"|g' cp4ba_LDAP.property.6 > cp4ba_LDAP.property.7
sed -r 's|LDAP_USER_DISPLAY_NAME_ATTR="<Required>"|LDAP_USER_DISPLAY_NAME_ATTR="cn"|g' cp4ba_LDAP.property.7 > cp4ba_LDAP.property.8
sed -r 's|LDAP_GROUP_BASE_DN="<Required>"|LDAP_GROUP_BASE_DN="dc=your,dc=company,dc=com"|g' cp4ba_LDAP.property.8 > cp4ba_LDAP.property.9
sed -r 's|LDAP_GROUP_NAME_ATTRIBUTE="<Required>"|LDAP_GROUP_NAME_ATTRIBUTE="*:cn"|g' cp4ba_LDAP.property.9 > cp4ba_LDAP.property.10
sed -r 's|LDAP_GROUP_DISPLAY_NAME_ATTR="<Required>"|LDAP_GROUP_DISPLAY_NAME_ATTR="cn"|g' cp4ba_LDAP.property.10 > cp4ba_LDAP.property.11
sed -r 's|LDAP_GROUP_MEMBERSHIP_SEARCH_FILTER="<Required>"|LDAP_GROUP_MEMBERSHIP_SEARCH_FILTER="(\&(cn=%v)(objectclass=groupOfUniqueNames))"|g' cp4ba_LDAP.property.11 > cp4ba_LDAP.property.12
sed -r 's|LDAP_GROUP_MEMBER_ID_MAP="<Required>"|LDAP_GROUP_MEMBER_ID_MAP="groupOfUniqueNames:uniqueMember"|g' cp4ba_LDAP.property.12 > cp4ba_LDAP.property.13
sed -r 's|LC_USER_FILTER="<Required>"|LC_USER_FILTER="(\&(uid=%v)(objectclass=person))"|g' cp4ba_LDAP.property.13 > cp4ba_LDAP.property.14
sed -r 's|LC_GROUP_FILTER="<Required>"|LC_GROUP_FILTER="(\&(cn=%v)(objectclass=groupOfUniqueNames))"|g' cp4ba_LDAP.property.14 > cp4ba_LDAP.property.15

echo "#### Copy last file to first file"
rm -f cp4ba_LDAP.property
cp cp4ba_LDAP.property.15 cp4ba_LDAP.property