#!/bin/bash

echo "#### Generate the final CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts

case ${CLOUDPLATFORMTYPE} in
  ROKS)
    echo "#### The cloud platform type is: ${CLOUDPLATFORMTYPE}"
    ./cp4a-deployment.sh <<EOF

Yes
No
2
a
1
1
Yes

Yes
EOF
    ;;
  OCP)
    echo "#### Cloud platform is: ${CLOUDPLATFORMTYPE}"
    ./cp4a-deployment.sh <<EOF

Yes
No
2
a
1
2
Yes

Yes
EOF
    ;;
  *)
    echo "#### Cloud platform is neither ROKS nor OCP, defaulting to Other"
    ./cp4a-deployment.sh <<EOF

Yes
No
2
a
1
3
Yes

Yes
EOF
    ;;
esac

#### Sample explanation of answers
#     # Press any key to continue (The script pressed Enter)
# Yes # Do you accept the IBM Cloud Pak for Business Automation license (Yes/No, default: No): 
# No    # Did you deploy Content CR (CRD: contents.icp4a.ibm.com) in current cluster? (Yes/No, default: No):
# 2   # What type of deployment is being performed? 1) Starter 2) Production Enter a valid option [1 to 2]:
# a   # Above CP4BA capabilities is already selected in the cp4a-prerequisites.sh script Press any key to continue
# 1   # Please select the deployment profile (default: small).  Refer to the documentation in CP4BA Knowledge Center for details on profile. 1) small 2) medium 3) large Enter a valid option [1 to 3]:
# 3   # Select the cloud platform to deploy: 1) RedHat OpenShift Kubernetes Service (ROKS) - Public Cloud 2) Openshift Container Platform (OCP) - Private Cloud 3) Other ( Certified Kubernetes Cloud Platform / CNCF) Enter a valid option [1 to 3]:
# Yes # Do you want to use the default IAM admin user: [cpadmin] (Yes/No, default: Yes):
#     # Provide a URL to zip file that contains JDBC and/or ICCSAP drivers. (optional - if not provided, the Operator will configure using the default shipped JDBC driver): (Pressed Enter)
# Yes # Verify that the information above is correct. To proceed with the deployment, enter "Yes". To make changes, enter "No" (default: No): (Pressed Enter)
