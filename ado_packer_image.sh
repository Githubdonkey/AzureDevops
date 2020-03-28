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
         export packerImageId=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
         export packerImageName=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
   elif [[ $packerProvider == "azure" ]]; then
         echo "Azure provider"
         export packerImageId=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
         export packerImageName=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
   else
        echo "manifest.json not found"
        exit 1
fi

aws secretsmanager create-secret --name builds/${packerProvider}/${packerImageName}/name --description "The image ${packerProvider} built ${packerOs} I created ${packerImage}"
aws secretsmanager create-secret --name builds/${packerProvider}/${packerImageId}/id --description "The image ${packerProvider} built ${packerOs} I created ${packerImage}"

aws secretsmanager put-secret-value --secret-id builds/${packerProvider}/${packerImage}/name --secret-string ${packerImageName}
aws secretsmanager put-secret-value --secret-id builds/${packerProvider}/${packerImage}/id --secret-string ${packerImageId}


# aws secretsmanager update-secret --secret-id builds/${packerProvider}/${packerImage} --secret-string {"imageID":"${TF_VAR_packer_name}"}

aws s3 cp manifest.json s3://gitdonkey/devops/${packerImageName}.json