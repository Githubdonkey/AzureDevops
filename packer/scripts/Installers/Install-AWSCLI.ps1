################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$name = "awscliv2"

New-Item -ItemType directory -Path C:\image\ps_modules\$name

Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\image\ps_modules\$name\$name.msi"

# $process = Start-Process -FilePath "wusa.exe" -ArgumentList "C:\image\ps_modules\$name\$name.msu /quiet /norestart" -Wait -PassThru
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\image\ps_modules\$name\$name.msi /quiet /norestart"  -Wait -PassThru

if(($process.ExitCode -eq 0 -Or $process.ExitCode -eq 3010))
{
    Write-Host "0 or 3010"
}
else
{
    Write-Host $process.ExitCode
    exit 1
}

# Get-Service -Name wuauserv | Start-Service