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

# Secrets Manager
```
# Create 
aws secretsmanager create-secret --name builds/firstImage --description "The secret I created for the first tutorial"
aws secretsmanager describe-secret --secret-id builds/firstImage
aws secretsmanager get-secret-value --secret-id builds/firstImage --version-stage AWSCURRENT
aws secretsmanager update-secret --secret-id builds/firstImage --description 'This is the description I want to attach to the secret.'
aws secretsmanager get-secret-value --secret-id builds/firstImage
aws secretsmanager get-secret-value --secret-id builds/firstImage --query SecretString --output text

# Get Secret value only
aws secretsmanager get-secret-value --secret-id builds/aws/ubuntu18-base | jq --raw-output .SecretString

# Update Secret value
aws secretsmanager put-secret-value --secret-id builds/aws/ubuntu18-base --secret-string sepersecet
```
# Parameter Store
create a policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter",
                "ssm:DeleteParameter",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:DeleteParameters"
            ],
            "Resource": "arn:aws:ssm:region:account-id:parameter/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ssm:DescribeParameters",
            "Resource": "*"
        }
    ]
}
```
Attach Policy to user
```
aws ssm put-parameter --name "/Test/IAD/helloWorld2" --value "My1stParameter8" --type String --overwrite
aws ssm get-parameter --name "/Test/IAD/helloWorld2" --output text --query Parameter.Value
```
=======

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
Create User
```
pip3 install awscli
pip3 install awscli --upgrade
```

### Set Envirornment Var for build machine

```
# AWS account info
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2

# Azure account info
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID=""
export ARM_TENANT_ID=""
```


# Setup linux machine
###### Install
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
installScripts/install-terraform.sh
```
###### Packer - install or update(sudo rm -r /usr/local/bin/)
```
installScripts/install-packer.sh
```
######  Set Variables
* Build machine: export PACKER_LOG_PATH="packer.log"
* Build machine: export PACKER_LOG=1
* Build machine: packer build -debug ubuntu_64.json

###### Windows Update Provisioner
Download latest binary https://github.com/rgl/packer-provisioner-windows-update/releases
```
tar -zxvf packer-provisioner-windows-update-linux.tgz
chmod +x packer-provisioner-windows-update
sudo cp packer-provisioner-windows-update /usr/local/bin/

example JSON
    {
      "type": "windows-update",
	  "search_criteria": "IsInstalled=0",
	  "filters": [
 		  "exclude:$_.Title -like '*Windows Defender Antivirus*'",
  		  "include:$true"
	  ]
    }
```

# Useful commands
###### Azure List images
* https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
```
az vm image list --output table
az vm image list --offer Debian --all --output table
az vm image list --location westeurope --offer Deb --publisher credativ --sku 8 --all --output table
az vm image list-skus --location westus --publisher Canonical --offer UbuntuServer --output table
az vm image show --location westus --urn Canonical:UbuntuServer:18.04-LTS:latest
```

###### Service Principal login
```
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
# Test access
az vm list-sizes --location eastus
```


ubuntu 20 server

http server
sudo python3 -m http.server 80

boot command
Boot Options: initrd=/casper/initrd autoinstall ds=nocloud-net;seedfrom=htpp://192.168.238.000:00/ ---

```
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - systemctl stop ssh # otherwise packer tries to connect and exceed max attempts
  network:
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: yes
          dhcp-identifier: mac
  apt:
    preserve_sources_list: false
    primary:
      - arches: [amd64]
        uri: "http://archive.ubuntu.com/ubuntu/"
  ssh:
    install-server: yes
    allow-pw: yes
  identity:
    hostname: ubuntu-00
    password: "$6$FhcddHFVZ7ABA4Gi$9l4yURWASWe8xEa1jzI0bacVLvhe3Yn4/G3AnU11K3X0yu/mICVRxfo6tZTB2noKljlIRzjkVZPocdf63MtzC0" # root
    username: ubuntu # root doesn't work
  packages:
    - open-vm-tools
  user-data:
    disable_root: false 
  late-commands:
    - echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/ubuntu
    - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 ipv6.disable=1 biosdevname=0"/' /target/etc/default/grub
    - curtin in-target --target /target update-grub2

```

Install desktop
```
sudo apt update
sudo apt install tasksel
sudo tasksel install ubuntu-desktop
sudo tasksel install ubuntu-desktop-minimal
reboot
if graphics dont start: sudo systemctl set-default graphical.target
```