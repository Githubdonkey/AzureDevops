################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

Install-PackageProvider -Name "Nuget" -Force
Install-Module -Name AWSPowerShell -Force