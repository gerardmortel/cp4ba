#!/bin/bash

echo "#### Edit the final CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/generated-cr
cp -p ibm_cp4a_cr_final.yaml ibm_cp4a_cr_final.yaml.orig

#sed -ri "s|sc_run_as_user:|sc_run_as_user: 1000670000|" ibm_cp4a_cr_final.yaml
#sed -ri "s/lc_ldap_user_name_attribute: \"\*:uid\"/lc_ldap_user_name_attribute: 'user:sAMAccountName'/" ibm_cp4a_cr_final.yaml
sed -ri "s/(lc_ldap_user_name_attribute:).*/\1 \"\*:cn\"/" ibm_cp4a_cr_final.yaml
sed -ri "s/(lc_ldap_user_display_name_attr:).*/\1 \"displayName\"/" ibm_cp4a_cr_final.yaml
#lc_ldap_group_base_dn: "dc=your,dc=company,dc=com"
sed -ri "s/(lc_ldap_group_name_attribute:).*/\1 \"\*:cn\"/" ibm_cp4a_cr_final.yaml
#lc_ldap_group_display_name_attr: "cn"
sed -ri "s/(    lc_ldap_group_membership_search_filter:).*/\1 (\&(cn=%v}(objectcategory=group))/" ibm_cp4a_cr_final.yaml
sed -ri "s/(    lc_ldap_group_member_id_map:).*/\1 'groupOfUniqueNames:uniqueMember'/" ibm_cp4a_cr_final.yaml
#sed -ri "s/(      lc_user_filter:).*/\1 (\&(cn=%v)(objectclass=inetOrgPerson))/" ibm_cp4a_cr_final.yaml
sed -ri "s/(      lc_user_filter:).*/\1 (\&(cn=%v)(objectclass=inetOrgPerson))/" ibm_cp4a_cr_final.yaml
#sed -ri "s/(      lc_group_filter:).*/\1 (\&(cn=*)(|(objectclass=groupofnames)(objectclass=groupofuniquenames)(objectclass=groupofurls)))/" ibm_cp4a_cr_final.yaml
sed -ri "s/(      lc_group_filter:).*/\1 >-\n        (\&(cn=%v)(|(objectclass=groupofnames)(objectclass=groupofuniquenames)(objectclass=groupofurls)))/" ibm_cp4a_cr_final.yaml
sed -ri "s/tds:/custom:/g" ibm_cp4a_cr_final.yaml
 ## The possible values are: "IBM Security Directory Server" or "Microsoft Active Directory" or "Custom"
sed -ri "s/( lc_selected_ldap_type:) \"IBM.*/\1 \"Custom\"/" ibm_cp4a_cr_final.yaml
sed -ri "s/(shared_configuration:)/\1\n    show_sensitive_log: true\n    ansible\.sdk\.operatorframework\.io\/verbosity: \"7\"/" ibm_cp4a_cr_final.yaml

  # ldap_configuration:
  #   ## The possible values are: "IBM Security Directory Server" or "Microsoft Active Directory"
  #   lc_selected_ldap_type: "Custom"
  #   ## The name of the LDAP server to connect
  #   lc_ldap_server: "openldap.cp4ba.svc.cluster.local"
  #   ## The port of the LDAP server to connect.  Some possible values are: 389, 636, etc.
  #   lc_ldap_port: "389"
  #   ## The LDAP bind secret for LDAP authentication.  The secret is expected to have ldapUsername and ldapPassword keys.  Refer to Knowledge Center for more info.
  #   lc_bind_secret: "ldap-bind-secret"
  #   ## The LDAP base DN.  For example, "dc=example,dc=com", "dc=abc,dc=com", etc
  #   lc_ldap_base_dn: "dc=your,dc=company,dc=com"
  #   ## Enable SSL/TLS for LDAP communication. Refer to Knowledge Center for more info.
  #   lc_ldap_ssl_enabled: false
  #   ## The name of the secret that contains the LDAP SSL/TLS certificate.
  #   lc_ldap_ssl_secret_name: "ibm-cp4ba-ldap-ssl-secret"
  #   ## The LDAP user name attribute. Semicolon-separated list that must include the first RDN user distinguished names. One possible value is "*:uid" for TDS and "user:sAMAccountName" for AD. Refer to Knowledge Center for more info.
  #   lc_ldap_user_name_attribute: "*:cn"
  #   ## The LDAP user display name attribute. One possible value is "cn" for TDS and "sAMAccountName" for AD. Refer to Knowledge Center for more info.
  #   lc_ldap_user_display_name_attr: "displayName"
  #   ## The LDAP group base DN.  For example, "dc=example,dc=com", "dc=abc,dc=com", etc
  #   lc_ldap_group_base_dn: "dc=your,dc=company,dc=com"
  #   ## The LDAP group name attribute.  One possible value is "*:cn" for TDS and "*:cn" for AD. Refer to Knowledge Center for more info.
  #   lc_ldap_group_name_attribute: "*:cn"
  #   ## The LDAP group display name attribute.  One possible value for both TDS and AD is "cn". Refer to Knowledge Center for more info.
  #   lc_ldap_group_display_name_attr: "cn"
  #   ## The LDAP group membership search filter string.  One possible value is "(|(&(objectclass=groupofnames)(member={0}))(&(objectclass=groupofuniquenames)(uniquemember={0})))" for TDS
  #   ## and "(&(cn=%v)(objectcategory=group))" for AD.
  #   lc_ldap_group_membership_search_filter: (&(cn=%v}(objectcategory=group))
  #   ## The LDAP group membership ID map.  One possible value is "groupofnames:member" for TDS and "memberOf:member" for AD.
  #   lc_ldap_group_member_id_map: 'groupOfUniqueNames:uniqueMember'
  #   ## The User script will uncomment the section needed based on user's input from User script.  If you are deploying without the User script,
  #   ## uncomment the necessary section (depending if you are using Active Directory (ad) or Tivoli Directory Service (tds)) accordingly.
  #   # ad:
  #   #   lc_ad_gc_host: "<Required>"
  #   #   lc_ad_gc_port: "<Required>"
  #   #   lc_user_filter: "(&(sAMAccountName=%v)(objectcategory=user))"
  #   #   lc_group_filter: "(&(cn=%v)(objectcategory=group))"
  #   custom:
  #     lc_user_filter: (&(cn=%v)(objectclass=inetOrgPerson))
  #     lc_group_filter: >-
  #       (&(cn=%v)(|(objectclass=groupofnames)(objectclass=groupofuniquenames)(objectclass=groupofurls)))
