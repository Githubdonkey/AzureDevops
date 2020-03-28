#!/bin/bash

packerProvider=$1
packerOs=$2
packerImage=$3

packerImageId=$(aws secretsmanager get-secret-value --secret-id builds/${packerProvider}/${packerImage}/id | jq --raw-output .SecretString)

# Run Terraform

echo "Starting Terraform build"
cp terraform/${packerProvider}_main_modules.tf main.tf
terraform init
# terraform plan -var="image_id=$packerImageId"
terraform apply -var="image_id=$packerImageId" -auto-approve
echo "sleep 5m"
sleep 5m
terraform destroy -var="image_id=$packerImageId" -auto-approve