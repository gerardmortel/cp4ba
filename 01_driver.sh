#!/bin/bash

echo "#### Running the driver file"
. ./02_setup_env.sh
./03_htpasswd_config.sh
./04_download_extract_case_file.sh
./05_create_project.sh
./06_ibm_entitlement_key_secret.sh
./07_configure_cluster_by_script.sh
./08_generate_property_files.sh
./09_edit_property_files.sh
./10_generate_property_files.sh
./11_create_secrets.sh