#az vm list --output table
#az vm get-instance-view -g ANSIBLEVM -n t20201211221609 --query id

#az sig list -o table

#az sig image-definition list --resource-group ImageGallery --gallery-name test2 -o table
#az sig image-version show --resource-group ImageGallery --gallery-name test2 --gallery-image-definition 2019_base --gallery-image-version 1.0.1

#(Get-AzGalleryImageVersion -ResourceGroupName ImageGallery -GalleryName test2 -GalleryImageDefinitionName 2019_base).Name

Select-AzSubscription Pay-As-You-Go

# create image definition
New-AzGalleryImageDefinition -ResourceGroupName "ImageGallery" -GalleryName "test2" -Name "2019_md" -Location "eastus" -Publisher "RMS" -Offer "2019_md" -Sku "Datacenter" -OsState "Generalized" -OsType "Windows" -Description "This is image"

# New Version
New-AzGalleryImageVersion -ResourceGroupName "ImageGallery" -GalleryName "test2" -GalleryImageDefinitionName "2019_md" -Name 1.0.1 -Location "eastus" -SourceImageId '/subscriptions/603917ef-28ce-417f-8107-d905c3fc11b2/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/SICFactory-Windows2019-md-1592087421'
New-AzGalleryImageVersion -ResourceGroupName "ImageGallery" -GalleryName "test2" -GalleryImageDefinitionName "2019_md" -Name 1.0.2 -Location "eastus" -SourceImageId '/subscriptions/603917ef-28ce-417f-8107-d905c3fc11b2/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/SICFactory-Windows2019-md-1592164665'

# image gallery snapshot
New-AzGalleryImageDefinition -ResourceGroupName "ImageGallery" -GalleryName "test2" -Name "rl_datadisk" -Location "eastus" -Publisher "RMS" -Offer "rl_datadisk" -Sku "Datacenter" -OsState "Specialized" -OsType "Windows" -Description "This is snapshot"
New-AzGalleryImageVersion -ResourceGroupName "ImageGallery" -GalleryName "test2" -GalleryImageDefinitionName "rl_datadisk" -Name 1.0.2 -Location "eastus" -SourceImageId '/subscriptions/603917ef-28ce-417f-8107-d905c3fc11b2/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/md1592175582'





# Update Image
$galleryImageVersion = (Get-AzGalleryImageVersion -ResourceGroupName ImageGallery -GalleryName test2 -GalleryImageDefinitionName 2019_md).Name
Write-Host $galleryImageVersion

$curver = $galleryImageVersion
Write-Host Current Version $curver
$tokens = $curver.Split(".")
$major = [int] ( $tokens[0] )
$minor = [int] ( $tokens[1] )
$patch = [int] ( $tokens[2] )

Write-Host Major $major
Write-Host Minor $minor
Write-Host Patch $patch

$patch = $patch + 1
$newVer = [string] ($major) + "." + [string] ($minor) + "." + [string] ($patch)
write-Host $newVer











$resourceGroupPacker = Get-AzResourceGroup -Name MyResourceGroup
$resourceGroup = Get-AzResourceGroup -Name ImageGallery
$gallery = Get-AzGallery -GalleryName test2
write-Host $galleryImageVersion


#$galleryImageVersion = Get-AzGalleryImageDefinition -ResourceGroupName $resourceGroup.ResourceGroupName -GalleryName $gallery.Name | Where {$_.Name -eq "2019_base"}
write-Host $galleryImageVersion
$curver = $galleryImageVersion.Name
Write-Host Current Version $curver
$tokens = $curver.Split(".")
$major = [int] ( $tokens[0] )
$minor = [int] ( $tokens[1] )
$patch = [int] ( $tokens[2] )

Write-Host Major $major
Write-Host Minor $minor
Write-Host Patch $patch

$patch = $patch + 1
$newVer = [string] ($major) + "." + [string] ($minor) + "." + [string] ($patch)
write-Host $newVer











packerProvider=$1
packerOs=$2
packerImage=$3

packerImageId=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --output text --query Parameter.Value)
packerImageName=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --output text --query Parameter.Value)

echo $packerImageId
echo $packerImageName

# Run Terraform
echo "Starting Terraform build"
cp terraform/${packerProvider}_main_${packerOs}.tf main.tf

cp terraform/userdata.sh userdata.sh

terraform init
terraform apply -var="ImageId=$packerImageId" -var="ImageName=$packerImageName" -auto-approve
echo "sleep 5m"
sleep 5m
terraform destroy -var="ImageId=$packerImageId" -var="ImageName=$packerImageName" -auto-approve