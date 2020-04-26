#!/bin/bash

packerProvider=$1
packerOs=$2
packerImage=$3

packerImageId=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --output text --query Parameter.Value)
packerImageName=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --output text --query Parameter.Value)
echo $packerImageId
echo $packerImageName
#if [[ $packerProvider == "aws" ]]; then
#        packerImageId=$(aws secretsmanager get-secret-value --secret-id builds/${packerProvider}/${packerImage}/id | jq --raw-output .SecretString)
#   elif [[ $packerProvider == "azure" ]]; then
#        packerImageId=$(aws secretsmanager get-secret-value --secret-id builds/${packerProvider}/${packerImage}/name | jq --raw-output .SecretString)
#   else
#        exit 1
#fi

# Run Terraform
echo "Starting Terraform build"
cp terraform/${packerProvider}_main_${packerOs}.tf main.tf
cp terraform/userdata.sh userdata.sh
#cp terraform/userdata.ps1 userdata.ps1

if [[ $packerProvider == "aws" ]]; then
        image_id=$packerImageId
   elif [[ $packerProvider == "azure" ]]; then
        image_id=$packerImageName
   else
        exit 1
fi

terraform init
terraform apply -var="image_id=$image_id" -auto-approve
echo "sleep 3m"
sleep 3m
terraform destroy -var="image_id=$image_id" -auto-approve