#!/bin/bash

packerProvider=$1
packerOs=$2
packerImage=$3

packerBuildFile=${packerProvider}-${packerOs}-${packerImage}.json
packerBuildVarFile=${packerProvider}-${packerOs}-${packerImage}.json

cp packer/$packerBuildFile $packerBuildFile
cp packer/SetUpWinRM.ps1 SetUpWinRM.ps1
cp packer/ec2-userdata.ps1 ec2-userdata.ps1
# tar -zxvf packages/packer-provisioner-windows-update-linux.tgz
# chmod +x packer-provisioner-windows-update
# sudo cp packer-provisioner-windows-update /usr/local/bin/packer-provisioner-windows-update
packer build $packerBuildFile

if [[ $packerProvider == "aws" ]]; then
         echo "AWS provider"
         export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
         export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
         echo "$TF_VAR_packer_image"
         echo "$TF_VAR_packer_name"
   elif [[ $packerProvider == "azure" ]]; then
         echo "Azure provider"
         export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
         export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
         echo "$TF_VAR_packer_image"
         echo "$TF_VAR_packer_name"
   else
        echo "manifest.json not found"
        exit 1
fi

# aws s3 cp manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json