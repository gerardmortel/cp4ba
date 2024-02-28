#!/bin/bash

echo "#### Running the driver file"
. ./02_setup_env.sh
./03_htpasswd_config.sh
./04_download_extract_case_file.sh
./05_create_project.sh
./06_ibm_entitlement_key_secret.sh
./07_configure_cluster_by_script.sh
./08_cp4a_prerequisites_property.sh
./09_edit_property_files.sh
./10_cp4a_prerequisites_generate.sh
./11_create_secrets.sh
./12_generate_final_cr.sh
./13_edit_final_cr.sh
# ./14_apply_cr.sh