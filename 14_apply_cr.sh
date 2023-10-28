#!/bin/bash

# Check if db2ucluster pod is running and ready every 10 seconds
oc project ${CP4BANAMESPACE}
while [ true ]
do
  oc get pods | grep "c-db2ucluster-cp4ba-db2u-0" | grep "Running" | grep "1/1"
  if [ $? -eq 0 ]; then
    echo "#### db2ucluster IS available"
    echo "#### Check if last ICNDB has been created"
    while [ true ]
    do
      oc exec c-db2ucluster-cp4ba-db2u-0 -- /mnt/blumeta0/home/db2inst1/sqllib/bin/db2 list db directory | grep ICNDB
      if [ $? -eq 0 ]; then
        echo "#### ICNDB database was found, exiting check ICNDB loop"
        break
      else
        echo "#### ICNDB database was NOT found, sleeping for 10 seconds"
        sleep 10
      fi
    done
    echo "#### Exiting check c-db2ucluster-cp4ba-db2u-0 is ready loop."
    break
  else
    echo "#### db2ucluster is NOT available."
    echo "#### Sleeping for 10 seconds"
    sleep 10
  fi
done

echo "#### Apply ibm_cp4a_cr_final.yaml CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/generated-cr
oc apply -f ibm_cp4a_cr_final.yaml

echo "#### Restart CP4A Operator"
oc get pod|grep ibm-cp4a-operator | awk '{print $1}' | xargs oc delete pod

echo "#### Wait 10 seconds for the operator to start then tail the stdout log"
sleep 10

echo "#### Get cp4ba operator pod full name"
pod=`(oc get pods | grep -v NAME | grep ibm-cp4a-operator | awk '{print $1}')`

echo "#### exec into cp4ba operator pod"
oc exec -it ${pod} -- bash

echo "#### Get close the directory to tail on the stdout"
cd /tmp/ansible-operator/runner/icp4a.ibm.com/v1/ICP4ACluster/cp4ba/icp4adeploy/artifacts

# directory=`(oc exec -it ${pod} -c operator -- ls -1 /tmp/ansible-operator/runner/icp4a.ibm.com/v1/ICP4ACluster/cp4ba/icp4adeploy/artifacts)`
# file="/tmp/ansible-operator/runner/icp4a.ibm.com/v1/ICP4ACluster/cp4ba/icp4adeploy/artifacts/"${directory}"/stdout"
# oc exec -it ${pod} -c operator -- tail -f ${file}
# oc exec -it ${pod} -c operator -- ls -1 /tmp/ansible-operator/runner/icp4a.ibm.com/v1/ICP4ACluster/cp4ba/icp4adeploy/artifacts