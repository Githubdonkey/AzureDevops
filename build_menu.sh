#!/bin/bash
echo "select the operation ************"
echo "  1)Packer Build Ubuntu 16"
echo "  2)Terraform plan"
echo "  3)Terraform apply"
echo "  4)operation 4" 

read n
case $n in
  1) terraform plan
     echo "You chose Option 1";;
  2) export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
   terraform plan 
   terraform apply -auto-approve;;
  3) export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
   terraform init
   terraform apply -auto-approve;;
  4) export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.managed_image_name' | tr -d '"')
   terraform destroy -auto-approve;;
  *) echo "invalid option";;
esac