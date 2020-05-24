################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

$start_time = Get-Date


Start-Sleep -Seconds 64

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Minutes) Minutes $((Get-Date).Subtract($start_time).Seconds) seconds"

$varPSversion = Get-Host | Select-Object Version
Write-Host $varPSversion

$min = Get-Date '08:00'
$max = Get-Date '17:30'

$now = Get-Date

if ('08:00' -le $now.TimeOfDay -and '11:00' -ge $now.TimeOfDay) {Write-Host $now.TimeOfDay; Write-Host "Group1"}
if ('11:01' -le $now.TimeOfDay -and '14:00' -ge $now.TimeOfDay) {Write-Host $now.TimeOfDay; Write-Host "Group2"}
if ('14:01' -le $now.TimeOfDay -and '17:00' -ge $now.TimeOfDay) {Write-Host $now.TimeOfDay; Write-Host "Group3"}
if ('17:01' -le $now.TimeOfDay -and '20:00' -ge $now.TimeOfDay) {Write-Host $now.TimeOfDay; Write-Host "Group4"}


#Parameter store entry to update image with group/scan
#aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --value "${packerImageName}" --type String --overwrite
#aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --value "${packerImageId}" --type String --overwrite

#packerImageId=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --output text --query Parameter.Value)
#packerImageName=$(aws ssm get-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --output text --query Parameter.Value)




#New-Item -ItemType directory -Path C:\image\ps_modules\$name

#Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu" -OutFile "C:\image\ps_modules\$name\$name.msu"

# $process = Start-Process -FilePath "wusa.exe" -ArgumentList "C:\image\ps_modules\$name\$name.msu /quiet /norestart" -Wait -PassThru
#Start-Process -FilePath wusa.exe -ArgumentList "C:\image\ps_modules\$name\$name.msu /extract:C:\image\ps_modules\$name"
#$process = Start-Process -FilePath dism.exe -ArgumentList " /online /add-package /PackagePath:C:\image\ps_modules\$name\WindowsBlue-KB3191564-x64.cab /Quiet /NoRestart" -PassThru -Wait

#if(($process.ExitCode -eq 0 -Or $process.ExitCode -eq 3010)){Write-Host "0 or 3010"}
#else{Write-Host $process.ExitCode; exit 1}

# Get-Service -Name wuauserv | Start-Service