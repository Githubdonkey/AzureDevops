#!/bin/bash

#tempvmname=md1592097069
#temprg=packer-md1592097069

echo "variables testing"
echo $temprg
echo $tempvmname
echo ${temprg}
echo ${tempvmname}

export dataDiskId=$(az disk list -g $temprg --query "[?contains(name,'datadisk-1')].[id]" -o tsv)

echo $dataDiskId

az disk list -g $temprg

az snapshot create -g myResourceGroup -n $tempvmname --source $dataDiskId

aws ssm put-parameter --name "/builds/RiskLink18/dataDisk" --value "${dataDiskId}" --type String --overwrite