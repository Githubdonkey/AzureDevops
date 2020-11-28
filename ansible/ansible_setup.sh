#!/bin/bash

#packerProvider=$1
#packerOs=$2
#packerImage=$3
#packerVarFileType=$4

#if test -z "$packerImage" 
#then
#      echo "\$packerImage is empty"
#      exit 0
#else
#      echo "\$packerImage is NOT empty"
#fi


cat <<EOF > /etc/ansible/hosts
[windows]
10.1.0.8
[linux]
10.1.0.6
10.1.0.7
EOF

cat <<EOF > /etc/ansible/group_vars/windows.yaml
ansible_user: localadm
ansible_password: thisPassChange@End
ansible_connection: winrm
ansible_winrm_transport: basic
ansible_winrm_port: 5985
ansible_winrm_server_cert_validation: ignore
EOF






















packerBuildFile=${packerProvider}-${packerOs}-${packerImage}.json
packerVarFile=var-${packerProvider}-${packerVarFileType}.json

cp packer/$packerBuildFile $packerBuildFile
cp packer/$packerVarFile $packerVarFile

cp packer/SetUpWinRM.ps1 SetUpWinRM.ps1
cp packer/ec2-userdata.ps1 ec2-userdata.ps1

#tar -zxvf packages/packer-provisioner-windows-update-linux.tgz
#chmod +x packer-provisioner-windows-update
#sudo cp packer-provisioner-windows-update /usr/local/bin/packer-provisioner-windows-update

packer build -var-file=$packerVarFile $packerBuildFile

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

aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --value "${packerImageName}" --type String --overwrite
aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --value "${packerImageId}" --type String --overwrite

echo "s3://gitdonkey/devops/${packerImageName}.html"
aws s3 cp aliases.html "s3://gitdonkey/devops/${packerImageName}.html"
echo "s3://gitdonkey/devops/${packerImageName}.json"
aws s3 cp manifest.json "s3://gitdonkey/devops/${packerImageName}.json"
echo "s3://gitdonkey/devops/${packerImageName}_packer_log.json"
aws s3 cp packer.log "s3://gitdonkey/devops/${packerImageName}_packer_log.json"

#aws secretsmanager create-secret --name builds/${packerProvider}/${packerOs}/name --description "The image ${packerProvider} built ${packerOs} I created ${packerImage}"
#aws secretsmanager create-secret --name builds/${packerProvider}/${packerImage}/id --description "The image ${packerProvider} built ${packerOs} I created ${packerImage}"

#aws secretsmanager put-secret-value --secret-id builds/${packerProvider}/${packerImage}/name --secret-string ${packerImageName}
#aws secretsmanager put-secret-value --secret-id builds/${packerProvider}/${packerImage}/id --secret-string ${packerImageId}

#aws s3 cp manifest.json s3://gitdonkey/devops/${packerImageName}.json
#aws s3 cp manifest.json s3://gitdonkey/devops/${packerImageName}_packer_log.json