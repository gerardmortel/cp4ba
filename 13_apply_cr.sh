#!/bin/bash

echo "#### Apply CR"
cd 
./cp4a-deployment.sh <<EOF

Yes

2

1
2


Yes
EOF

cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/generated-cr
oc apply -f ibm_cp4a_cr_final.yaml