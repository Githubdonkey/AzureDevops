################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

$varPSversion = Get-Host | Select-Object Version
$name = "ps51"
Write-Host $varPSversion

New-Item -ItemType directory -Path C:\image\ps_modules\$name

Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu" -OutFile "C:\image\ps_modules\$name\$name.msu"

# $process = Start-Process -FilePath "wusa.exe" -ArgumentList "C:\image\ps_modules\$name\$name.msu /quiet /norestart" -Wait -PassThru
Start-Process -FilePath "wusa.exe" -ArgumentList "C:\image\ps_modules\$name\$name.msu /extract:C:\image\ps_modules\$name"
$process = Start-Process -FilePath dism.exe -ArgumentList " /online /add-package /PackagePath:C:\image\ps_modules\$name\WindowsBlue-KB3191564-x64.cab /Quiet /NoRestart" -PassThru -Wait

if(($process.ExitCode -eq 0 -Or $process.ExitCode -eq 3010))
{
    Write-Host "0 or 3010"
}
else
{
    Write-Host $process.ExitCode
    exit 1
}

Write-Host $varPSversion

Get-Service -Name wuauserv | Start-Service