#!/bin/bash

packerProvider=$1
packerOs=$2
packerImage=$3
packerVarFileType=$4

if test -z "$packerImage" 
then
      echo "\$packerImage is empty"
      exit 0
else
      echo "\$packerImage is NOT empty"
fi

echo $packerProvider
echo $packerOs
echo $packerImage
echo $packerVarFileType

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
terraform output
pwd
ls
aws s3 cp terraform.tfstate "s3://gitdonkey/devops/tf_${packerImageName}.tfstate"
if [ -f terraform.tfstate ]; then
   rm terraform.tfstate
   echo "terraform.tfstate is removed"
fi
ls
echo "sleep 2m"
#sleep 2m
#ls
#aws s3 cp "s3://gitdonkey/devops/tf_${packerImageName}.tfstate" terraform.tfstate
#terraform destroy -auto-approve