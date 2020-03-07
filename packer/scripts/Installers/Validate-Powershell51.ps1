################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

$varPSversion = Get-Host | Select-Object Version

Write-Host $varPSversion

$varPackages = Get-Package

Write-Host $varPackages

$Description = @"
_Version:_ $varPSversion<br/>
_Version:_ $varPackages<br/>
"@

Write-Host $Description