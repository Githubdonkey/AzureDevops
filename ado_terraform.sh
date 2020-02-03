#!/bin/bash
selection=$1
selectionImage=$2

echo "************** select the operation ************"
echo "   1) Test"
echo "************** AWS ******************************"
echo "  11) Terraform Build Ubuntu 18 "
echo ""
echo "************** Azure ****************************"
echo "  21) Packer Build Ubuntu 18 Market Place"
echo "  22) Packer Build Windows 2019 Market Place"
echo "  23) Terraform Ubuntu 18"
echo "  24) Terraform Windows "
echo "  25) operation 4"

case $selection in
  1) echo "You chose Option 1"
      exit;;
  11) echo "You chose Option 11"
      packerProvider=aws;;
  12) echo "You chose Option 12"
      packerState=true; packerProvider=aws; packerOs=win2012R2; packerSource=marketplace; packerFunction=base; terraformState=false; s3upload=true;;
  13) echo "You chose Option 13" 
     packerState=true; packerProvider=aws; packerOs=win2012R2; packerSource=marketplace; packerFunction=default; terraformState=false; s3upload=true;;
  14) echo "You chose Option 14" 
     packerState=true; packerProvider=aws; packerOs=win2016; packerSource=marketplace; packerFunction=base; terraformState=false; s3upload=true;;
  15) echo "You chose Option 15" 
     packerState=true; packerProvider=aws; packerOs=win2019; packerSource=marketplace; packerFunction=base; terraformState=false; s3upload=true;;
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
      packerState=true; packerProvider=azure; packerOs=ubuntu18; packerSource=marketplace; packerFunction=base; terraformState=false; s3upload=true;;
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

# Run Terraform

   echo "Starting Terraform build"
   cp terraform/${packerProvider}_main_modules.tf main.tf
   echo $selectionImage
   terraform init
   terraform plan -var="image_id=$selectionImage"
   terraform apply -var="image_id=$selectionImage" -auto-approve
   echo "sleep 4m"
   sleep 4m
   terraform destroy -var="image_id=$selectionImage" -auto-approve