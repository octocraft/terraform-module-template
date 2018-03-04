#!/bin/bash
set -eu

if [ -z "${TERRAFORM_VERSION+x}" ]; then
    TERRAFORM_VERSION='0.11.3'
fi

tf_type='archive'; 
tf_name='terraform'; 
tf_ver="$TERRAFORM_VERSION"; 
tf_url='https://releases.hashicorp.com/terraform/${version}/${name}_${version}_${sbpl_os}_${sbpl_arch}.zip'
tf_bin='./'

sbpl_get "$tf_type" "$tf_name" "$tf_ver" "$tf_url" "$tf_bin"

if command -v wine &> /dev/null; then
    sbpl_os="windows"; sbpl_arch="386";
    sbpl_get "$tf_type" "$tf_name" "$tf_ver" "$tf_url" "$tf_bin"
fi
