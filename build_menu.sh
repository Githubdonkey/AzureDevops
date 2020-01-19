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
     packer build aws_ubuntu18_latest_marketplace.json;;
  12) echo "You chose Option 12" 
     cd packer/
     packer build aws_win2016_latest_marketplace.json
     export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
     aws s3 cp packer/manifest.json s3://gitdonkey/devops/${TF_VAR_packer_image}.json;;
  13)echo "AWS check for latest Packer Image"
     if [ -z "$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"'| cut -d':' -f2)" ]
      then
      echo "$(tput setaf 1) \$TF_VAR_packer_image is empty$(tput sgr 0)"
        else
      echo "\$TF_VAR_packer_image is NOT empty"
        fi
     export TF_VAR_packer_image=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"'| cut -d':' -f2)
     export TF_VAR_packer_image1=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
     echo $TF_VAR_packer_image
     echo $TF_VAR_packer_image1;;
     #terraform plan;;
     #terraform apply -auto-approve;;
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