################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

Set-AWSCredential –AccessKey $Env:AWS_ACCESS_KEY_ID –SecretKey $Env:AWS_SECRET_ACCESS_KEY -StoreAs defaut 
#Set-DefaultAWSRegion -Region us-east-1

Read-S3Object -BucketName gitdonkey -Key devops/installers/packer_1.5.1_linux_amd64.zip -File packer_1.5.1_linux_amd64.zip

Write-S3Object -BucketName gitdonkey -Key devops/packer_1.5.1_linux_amd64.zip -File packer_1.5.1_linux_amd64.zip

# Write-S3Object -BucketName $s3Bucket -Folder $sourcePath -KeyPrefix $s3Path -SearchPattern "*.tif"