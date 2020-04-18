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
terraform init
# terraform plan -var="ImageId=${packerImageId}"
terraform apply -var="ImageId=$packerImageId" -var="ImageName=$packerImageName" -auto-approve
echo "sleep 5m"
sleep 5m
terraform destroy -var="ImageId=$packerImageId" -auto-approve