################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

$varPSversion = Get-Host | Select-Object Version

Write-Host $varPSversion

$varPackages = Get-WmiObject -Class Win32_Product | Select-Object Name, Version

Write-Host $varPackages

$Description = @"
_Version:_ $varPSversion<br/>
_Version:_ $varPackages<br/>
"@

Write-Host $Description

#Get-WmiObject -Class Win32_Product | Select-Object Name, Version | ConvertTo-Html | Out-File C:\Users\tom\Desktop\repo\CI\AzureDevops\test.html