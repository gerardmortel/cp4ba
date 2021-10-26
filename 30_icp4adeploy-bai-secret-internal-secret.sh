#!/bin/bash
oc project ${CP4BANAMESPACE}

apiVersion: v1
kind: Secret
metadata:
  name: custom-bai-secret
# Credentials
stringData:
# Administration Service secrets
  admin-username: <username to authenticate against the admin REST API>
  admin-password: <password to authenticate against the admin REST API>
  # Management Service secrets
  management-username: <username to authenticate against the management REST API>
  management-password: <password to authenticate against the management REST API>
  # Flink
  flink-security-krb5-realm: <Name of the Kerberos default realm>
  flink-security-krb5-kdc: <Kerberos Key Distribution Center host>
  flink-security-krb5-principal: <Kerberos principal>
  flink-security-krb5-keytab: <Kerberos Keytab>
  # Kibana
  kibana-username: <username for communication with an external Kibana>
  kibana-password: <password for communication with an external Kibana>

  # Certificates and keys
data:
  # Kibana
  kibana-cert: <base64-encoded certificate in PEM format for secure communication with an external Kibana>
