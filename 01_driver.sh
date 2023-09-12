#!/bin/bash
. ./02_setup_env.sh
./03_htpasswd_config.sh
./04_download_extract_case_file.sh
./05_create_namespace.sh
./06_ibm_entitlement_key_secret.sh