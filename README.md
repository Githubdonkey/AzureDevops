# Git
```
git clone https://github.com/Githubdonkey/AzureDevops.git # Create repository on local machine
git status # Get current status of repo

#Branches
git branch login # this creates the login branch
git checkout login # this changes to your login branch
git checkout master # this changes to master branch

#Git ignore
touch .gitignore # add files to this to exclude

# push Local (script available ./gitPush.sh)
git add .
git commit -m "your comment"
git push

# First push "git push --set-upstream origin pipeline_work"

```
# AzureDevops
Sign up for an account

connect git hub : Approve & Install Azure Pipelines

# Azure Setup
## Portal Cloud Shell(Powershell)
##### Create Service Principle 
```
#get Subscription ID info from output(ID value)
az account list
#Set Subscription ID
az account set --subscription="SUBSCRIPTION_ID"
# Create SP
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```
Output(appId is the client_id)
```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```
# AWS Setup

### Set Envirornment Var for build machine

```
# AWS account info

# Powershell
PS C:\> $Env:AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
PS C:\> $Env:AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
PS C:\> $Env:AWS_DEFAULT_REGION="us-east-1"
# Linux
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-west-2

# Azure account info

# Powershell
PS C:\> $Env:ARM_CLIENT_ID=""
PS C:\> $Env:ARM_CLIENT_SECRET=""
PS C:\> $Env:ARM_SUBSCRIPTION_ID=""
PS C:\> $Env:ARM_TENANT_ID=""
# Linux
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID=""
export ARM_TENANT_ID=""
```
###### Service Principal login
```
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
# Test access
az vm list-sizes --location eastus
```

###### setup azure packer
```
* create resource group
* New-AzResourceGroup -Name "myResourceGroup" -Location "East US"
```



## Azure List images
* https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
```
az vm image list --output table
az vm image list --offer Debian --all --output table
az vm image list --location westeurope --offer Deb --publisher credativ --sku 8 --all --output table
az vm image list-skus --location westus --publisher Canonical --offer UbuntuServer --output table
az vm image show --location westus --urn Canonical:UbuntuServer:18.04-LTS:latest
```

## Setup linux machine
```
sudo apt-get install unzip
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
sudo apt install curl
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update
sudo apt-get install azure-functions-core-tools
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
###### Terraform
```
terraform-install.sh
```
###### Packer - install or update(sudo rm -r /usr/local/bin/)
```
VER=1.4.5
wget https://releases.hashicorp.com/packer/${VER}/packer_${VER}_linux_amd64.zip
unzip packer_${VER}_linux_amd64.zip
sudo mv packer /usr/local/bin
```
## Set up Packer Logging
###### UNIX
* Build machine: export PACKER_LOG_PATH="/home/test/packer.log"
* Build machine: export PACKER_LOG=1
* Build machine: packer build -debug ubuntu_64.json

###### WINDOWS
* Build machine: set PACKER_LOG=1
* Build machine: set PACKER_LOG_PATH=c:\temp\packer log
* Build machine: packer build -debug ubuntu_64.json
