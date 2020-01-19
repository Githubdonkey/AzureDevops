#!/bin/bash

# Check for Azure login Variable
if [ -z "$AWS_ACCESS_KEY_ID" ]
then
      echo "$(tput setaf 1) \$AWS_ACCESS_KEY_ID is empty$(tput sgr 0)"
else
      echo "\$AWS_ACCESS_KEY_ID is NOT empty"
fi
# Check for Azure login Variable
if [ -z "$ARM_CLIENT_ID" ]
then
      echo "$(tput setaf 1) \$ARM_CLIENT_ID is empty$(tput sgr 0)"
else
      echo "\$ARM_CLIENT_ID is NOT empty"
fi

echo "************** select the operation ************"
echo ""
echo "************** AWS ******************************"
echo "  11) Packer Build Ubuntu 18 Market Place"
echo "  12) Packer Build Windows 2016 Market Place"
echo "  13) Terraform Ubuntu 18"
echo "  14) Terraform modules"
echo ""
echo "************** Azure ****************************"
echo "  21) Packer Build Ubuntu 18 Market Place"
echo "  22) Packer Build Windows 2019 Market Place"
echo "  23) Terraform Ubuntu 18"
echo "  24) Terraform Windows 2019"
echo "  25) operation 4" 

read n
case $n in
  11) echo "You chose Option 11" 
     cd packer/
     packer build aws_ubuntu18_latest_marketplace.json
     export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
     export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.AMI_Name' | tr -d '"')
     aws s3 rm s3://bucket-name/ami --recursive
     aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_image}.json
     aws s3 cp manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json;;

  12) echo "You chose Option 12" 
     cd packer/
     packer build aws_win2016_latest_marketplace.json
     export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
     aws s3 cp packer/manifest.json s3://gitdonkey/devops/${TF_VAR_packer_image}.json;;

  13) string=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.name')
     if [[ $string == *"amazon"* ]]; then
        echo "AWS is NOT empty"
        export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
        cp terraform/aws_main.tf dev/main.tf
     elif [[ $string == *"azure-arm"* ]]; then
        echo "Azure is NOT empty"
        export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
        #terraform plan;;
     else
        echo "packer/manifest.json not found"
     fi
     echo $TF_VAR_packer_image
     cd dev/
     terraform init
     terraform plan -var="image_id=$TF_VAR_packer_image"
     terraform apply -var="image_id=$TF_VAR_packer_image" -auto-approve
     echo "sleep 4m"
     sleep 4m
     terraform destroy -var="image_id=$TF_VAR_packer_image" -auto-approve;;

  14) string=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.name')
     if [[ $string == *"amazon"* ]]; then
        echo "AWS is NOT empty"
        export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
        rm -r dev/*
        cp terraform/aws_main_modules.tf dev/main.tf
     elif [[ $string == *"azure-arm"* ]]; then
        echo "Azure is NOT empty"
        export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
     else
        echo "packer/manifest.json not found"
     fi
     echo $TF_VAR_packer_image
     cd dev/
     terraform init
     terraform plan -var="image_id=$TF_VAR_packer_image";;
     #terraform apply -var="image_id=$TF_VAR_packer_image" -auto-approve
     #echo "sleep 4m"
     #sleep 4m
     #terraform destroy -var="image_id=$TF_VAR_packer_image" -auto-approve;;

  21) echo "You chose Option 21" 
     cd packer/
     packer build azure_ubuntu18_latest_marketplace.json;;
  22) echo "You chose Option 22" 
     cd packer/
     packer build azure_win2019_latest_marketplace.json;;
  23) echo "Azure check for latest Packer Image" 
     export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
     terraform plan;;
     #terraform apply -auto-approve;;
  24) export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
     terraform plan;;
     #terraform apply -auto-approve;;
  7) export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
     terraform init
     terraform apply -auto-approve;;
  8) export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
     terraform destroy -auto-approve;;
  *) echo "invalid option";;
esac