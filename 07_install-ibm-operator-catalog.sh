#!/bin/bash
oc apply -f yaml/ibm-operator-catalog.yaml
oc apply -f yaml/opencloud-operators.yaml
