#!/bin/bash
selection=$1

echo "************** select the operation ************"
echo "   1) Azure Test"
echo "   2) AWS Windows Update"
echo "************** AWS ******************************"
echo "  11) Packer Build Ubuntu 18 Market Place"
echo "  12) Packer Build Windows 2012R2 Base Market Place"
echo "  13) Packer Build Windows 2012R2 Default Place"
echo "  14) Packer Build Windows 2016 Base Market Place"
echo "  15) Packer Build Windows 2016 Default Market Place"
echo "  16) Packer Build Windows 2019 Base Market Place"
echo ""
echo "************** Azure ****************************"
echo "  21) Packer Build Ubuntu 18 Market Place"
echo "  22) Packer Build Windows 2012R2 Base Market Place"
echo "  23) Packer Build Windows 2012R2 Default Market Place"
echo "  24) Packer Build Windows 2016 Base Market Place"

case $selection in
  1) echo "You chose Option 1"
      packerProvider=azure; packerOs=win2012R2; packerFunction=test; packerSource=marketplace;;
  2) echo "You chose Option 2"
      packerProvider=aws; packerOs=win2016; packerFunction=winUpdate; packerSource=marketplace;;
  11) echo "You chose Option 11"
      packerProvider=aws; packerOs=ubuntu18; packerFunction=base; packerSource=marketplace;;
  12) echo "You chose Option 12"
      packerProvider=aws; packerOs=win2012R2; packerFunction=base; packerSource=marketplace;;
  13) echo "You chose Option 13" 
      packerProvider=aws; packerOs=win2012R2; packerFunction=default; packerSource=marketplace;;
  14) echo "You chose Option 14" 
      packerProvider=aws; packerOs=win2016; packerFunction=base; packerSource=marketplace;;
  15) echo "You chose Option 15" 
      packerProvider=aws; packerOs=win2016; packerFunction=default; packerSource=marketplace;;
  16) echo "You chose Option 16" 
      packerProvider=aws; packerOs=win2019; packerFunction=default; packerSource=marketplace;;
  21) echo "You chose Option 21"
      packerProvider=azure; packerOs=ubuntu18; packerFunction=base; packerSource=marketplace;;
  22) echo "You chose Option 22"
      packerProvider=azure; packerOs=win2012R2; packerFunction=base; packerSource=marketplace;;
  23) echo "You chose Option 23"
      packerProvider=azure; packerOs=win2012R2; packerFunction=default; packerSource=marketplace;;
  24) echo "You chose Option 24"
      packerProvider=azure; packerOs=win2016; packerFunction=base; packerSource=marketplace;;
  *) echo "invalid option";;
esac
packerBuildFile=${packerProvider}_${packerOs}_${packerFunction}_${packerSource}.json
cp packer/$packerBuildFile $packerBuildFile
cp packer/SetUpWinRM.ps1 SetUpWinRM.ps1
chmod +x packer/packer-provisioner-windows-update
sudo cp packer/packer-provisioner-windows-update /usr/local/bin/packer-provisioner-windows-update
packer build $packerBuildFile

if [[ $packerProvider == "aws" ]]; then
         echo "AWS provider"
         export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"' | cut -d':' -f2)
         export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
         echo "$TF_VAR_packer_image"
         echo "$TF_VAR_packer_name"
   elif [[ $packerProvider == "azure" ]]; then
         echo "Azure provider"
         export TF_VAR_packer_image=$(cat manifest.json | jq '.builds | to_entries[] | .value.artifact_id' | tr -d '"')
         export TF_VAR_packer_name=$(cat manifest.json | jq '.builds | to_entries[] | .value.custom_data.name' | tr -d '"')
         echo "$TF_VAR_packer_image"
         echo "$TF_VAR_packer_name"
   else
        echo "manifest.json not found"
        exit 1
fi

#aws s3 cp manifest.json s3://gitdonkey/devops/${TF_VAR_packer_name}.json