#!/bin/bash

packerProvider=$1
packerOs=$2
packerImage=$3

echo $packerProvider
echo $packerOs
echo $packerImage

packerImageId=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --output text --query Parameter.Value)
packerImageName=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --output text --query Parameter.Value)

#aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --value "${packerImageName}" --type String --overwrite
#aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --value "${packerImageId}" --type String --overwrite

echo $packerImageId
echo $packerImageName

# Run Terraform
echo "Starting Terraform build"
cp terraform/${packerProvider}_main_${packerOs}.tf main.tf

cp terraform/userdata.sh.tpl userdata.sh.tpl

terraform init
terraform apply -var="ImageId=$packerImageId" -var="ImageName=$packerImageName" -auto-approve
echo "sleep 5m"
sleep 5m
terraform destroy -var="ImageId=$packerImageId" -var="ImageName=$packerImageName" -auto-approve