if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
}

#Import-Module -Name Az

Get-AzResourceGroupDeployment -ResourceGroupName myResourceGroup

Login-AzureRmAccount
Get-AzureRMSubscription
Select-AzureRmSubscription -SubscriptionName 'Pay-As-You-Go'


$resourceGroupName = "myResourceGroup"
$vmName="test111"
$Location = "eastus"
$snapshotName = "testDataDisk2"


$vm = get-azureRmVm -ResourceGroupName $resourceGroupName -Name $vmName

$vmOSDisk=(Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName).StorageProfile.DataDisk.Name
Write-Host $vmOSDisk
$Disk = Get-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $vmOSDisk
Write-Host $Disk
$SnapshotConfig = New-AzureRmSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location
Write-Host $SnapshotConfig
$Snapshot = New-AzureRmSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

az disk list

datadisk=$()
$datadiskvar = "md1592086507_DataDisk_0"

az snapshot create -g MyResourceGroup -n MySnapshot2 --source "/subscriptions/603917ef-28ce-417f-8107-d905c3fc11b2/resourceGroups/MYRESOURCEGROUP/providers/Microsoft.Compute/disks/test111_disk1_0da24e62e4d04590b2aee2dc7931c369"

$osDiskId=$(az vm show -g myResourceGroup -n test111 --query "storageProfile.osDisk.managedDisk.id" -o tsv)
$dataDiskId=$(az disk list -g myResourceGroup --query "[?contains(name,'DataDisk_0')].[id]" -o tsv)

az vm show -g myResourceGroup -n test111 --query storageProfile.osDisk.managedDisk.id -o tsv
az vm show -g myResourceGroup -n test111 --query "[?contains(name,'DataDisk_0')].[id]" -o tsv
az disk list -g myResourceGroup --query "[?contains(name,'test111_DataDisk_0')].[id]" -o tsv
az disk list -g myResourceGroup --query "[?contains(name,'$datadiskvar')].[id]" -o tsv
az disk list -g myResourceGroup --query "[?contains(name,'$datadiskvar')].[id]" -o tsv
md1592086507

az disk create -g MyResourceGroup -n MyDisk2 --source MyDisk


az vm show -g packer-md1592092481 -n md1592087421 --query "[?contains(name,'datadisk-1')].[id]" -o tsv

$dataDiskId=$(az disk list -g packer-md1592092481 --query "[?contains(name,'datadisk-1')].[id]" -o tsv)
az disk list -g packer-md1592092481 --query "[?contains(name,'datadisk-1')].[id]" -o tsv

az snapshot create -g MyResourceGroup -n MySnapshot5 --source $osDiskId
az snapshot create -g MyResourceGroup -n MySnapshot44 --source $dataDiskId

# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/snapshot-copy-managed-disk
# If you would like to store your snapshot in zone-resilient storage, you need to create it in a region that supports availability zones and include the --sku Standard_ZRS parameter.


{
    "type": "shell-local",
    "inline":[  
        "echo test1",
        "echo {{user `temp_compute_name`}}_DataDisk_0",
        "export datadiskvar={{user `temp_compute_name`}}_DataDisk_0",
        "az disk list -g {{user `temp_resource_group_name`}}",
        "az disk list -g {{user `temp_resource_group_name`}} --query \"[?contains(name,'data-disk-1')].[id]\" -o tsv",
        "echo $datadiskvar",
        "export OUTPUT=$(az disk list -g {{user `temp_resource_group_name`}} --query '[?contains(name,'data-disk-1')].[id]' -o tsv)",
        "echo ${OUTPUT}"
     ]
},

{
    "type": "shell-local",
    "environment_vars": [
    "tempvmname={{user `temp_compute_name`}}",
    "temprg={{user `temp_resource_group_name`}}"
],
    "script": "ado_dataDiskpy.sh",
    "execute_command": ["/bin/sh", "-c", "{{.Vars}}", "{{.Script}}"]
},

https://docs.microsoft.com/en-us/cli/azure/disk?view=azure-cli-latest





# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh