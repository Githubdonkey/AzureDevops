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
echo "  12) Packer Build Windows 2012R2 Market Place"
echo "  13) Packer Build Windows 2016 Market Place"
echo "  14) Packer Build Windows 2019 Market Place"
echo "  15) Packer Build Ubuntu 18 & Terraform"
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
     packerState=true
     packerProvider=aws
     packerOs=ubuntu18
     packerSource=marketplace
     packerFunction=base
     terraformState=false
     s3upload=true
     ;;
  12) echo "You chose Option 12" 
     packerState=true
     packerProvider=aws
     packerOs=win2012R2
     packerSource=marketplace
     packerFunction=base
     terraformState=false
     s3upload=true
     ;;

  13) echo "You chose Option 13" 
     packerState=true
     packerProvider=aws
     packerOs=win2016
     packerSource=marketplace
     packerFunction=base
     terraformState=false
     s3upload=true
     ;;
   
   14) echo "You chose Option 14" 
     packerState=true
     packerProvider=aws
     packerOs=win2019
     packerSource=marketplace
     packerFunction=base
     terraformState=false
     s3upload=true
     ;;

  15) echo "chose 15"
     packerState=true
     packerProvider=aws
     packerOs=ubuntu18
     packerSource=marketplace
     packerFunction=base
     terraformState=true
     s3upload=true
     ;;

  16) string=$(cat packer/manifest.json | jq '.builds | to_entries[] | .value.name')
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
     packer build azure_ubuntu18_latest_marketplace.json
     export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d'/' -f9)
     export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.Name' | tr -d '"')
     #export TF_VAR_packer_name_os=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name_os' | tr -d '"')

     #aws s3 rm s3://gitdonkey/devops/ --recursive --exclude "*" --include "${TF_VAR_packer_name_os}*"
     #aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_image}.json
     aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_name}.json
     aws s3 cp manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json;;
  22) echo "You chose Option 22" 
     cd packer/
     packer build azure_win2019_latest_marketplace.json
     export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d'/' -f9)
     export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.Name' | tr -d '"')
     #export TF_VAR_packer_name_os=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name_os' | tr -d '"')

     #aws s3 rm s3://gitdonkey/devops/ --recursive --exclude "*" --include "${TF_VAR_packer_name_os}*"
     #aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_image}.json
     aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_name}.json
     aws s3 cp manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json;;
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

if [[ $packerState == "true" ]]; then
      packerBuildFile=${packerProvider}_${packerOs}_${packerFunction}_${packerSource}.json
      rm -r dev/*
      cp packer/$packerBuildFile dev/$packerBuildFile
      cp packer/bootstrap_win.txt dev/bootstrap_win.txt
      cd dev/
      packer build $packerBuildFile
      cd ..
fi

if [[ $packerProvider == "aws" ]]; then
         echo "AWS provider"
         export TF_VAR_packer_image=$(cat dev/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
         export TF_VAR_packer_name=$(cat dev/manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
   elif [[ $packerProvider == "azure" ]]; then
         echo "Azure provider"
         export TF_VAR_packer_image=$(cat dev/manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
         export TF_VAR_packer_name=$(cat dev/manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
   else
        echo "dev/manifest.json not found"
        exit 1
fi

if [[ $s3Upload == "true" ]]; then
      #aws s3 rm s3://gitdonkey/devops/ --recursive --exclude "*" --include "${TF_VAR_packer_name_os}*"
      #aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_image}.json
      #aws s3 cp manifest.json s3://gitdonkey/devops/image_build_repo/${TF_VAR_packer_name}.json
      aws s3 cp dev/manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json
fi

# Run Terraform
if [[ $terraformState == "true" ]]; then
         echo "Starting Terraform build"
         cp terraform/${packerProvider}_main_modules.tf dev/main.tf
         echo $TF_VAR_packer_image
         cd dev/
         terraform init
         terraform plan -var="image_id=$TF_VAR_packer_image"
         terraform apply -var="image_id=$TF_VAR_packer_image" -auto-approve
         echo "sleep 4m"
         sleep 4m
         terraform destroy -var="image_id=$TF_VAR_packer_image" -auto-approve
fi