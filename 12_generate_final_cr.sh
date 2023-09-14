#!/bin/bash

echo "#### Generate the final CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-deployment.sh <<EOF

Yes

2

1
2


Yes
EOF
