#!/bin/bash
oc project ${CP4BANAMESPACE}

# Create a new service account named ibm-es-service-account
oc create serviceaccount ${IBMESSERVICEACCOUNT}

# Add system-privileged security context constraint (SCC) to the newly created service account
oc adm policy add-scc-to-user privileged -z ibm-es-service-account -n ${CP4BANAMESPACE}
