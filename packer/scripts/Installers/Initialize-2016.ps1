# Set TLS1.2

$ImageDetails= @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
table {border:1px solid black;margin-left:auto;margin-right:auto;}
div {margin:0px auto;BACKGROUND-COLOR:Black;Color:White;font-weight:bold;FONT-SIZE:16pt;TEXT-ALIGN:center;}
</style>
</head><body>
<div style='margin:  0px auto; BACKGROUND-COLOR:Black;Color:White;font-weight:bold;FONT-SIZE:  16pt;TEXT-ALIGN: center;'>
<i>$Env:Computername  Image Report</i>
<BR><i>Description $Env:Computername</i>
<BR><i>Report generated on $((Get-Date).ToString())</i>
</div>
<BR>
<i><b>Image Name:</b> $Env:Computername</i><BR>
<i><b>Image Description:</b> $Env:Computername</i><BR>
<i><b>Hard Drive size:</b> $Env:Computername</i><BR>
<i><b>Platform:</b> $Env:Computername</i>
"@

$ImageDetails | Out-File C:\image\aliases.html

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

Write-Host "Setup PowerShellGet"
# Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-Module -Name PowerShellGet -Force
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

# Disable Windows Update
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
If (Test-Path -Path $AutoUpdatePath) {
    Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1
    Write-Host "Disabled Windows Update"
}
else {
    Write-Host "Windows Update key does not exist"
}

# Install Windows .NET Features
Write-Host "Install-WindowsFeature -Name NET-Framework-Features 2.0 3.5"
Install-WindowsFeature -Name NET-Framework-Features -IncludeAllSubFeature
Write-Host "Install-WindowsFeature -Name NET-Framework-45-Features"
Install-WindowsFeature -Name NET-Framework-45-Features -IncludeAllSubFeature
#Install-WindowsFeature -Name BITS -IncludeAllSubFeature
#Install-WindowsFeature -Name DSC-Service


Write-Host "Setting local execution policy"
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -ErrorAction Continue | Out-Null
Get-ExecutionPolicy -List

Write-Host "Install chocolatey"
$chocoExePath = 'C:\ProgramData\Chocolatey\bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
    Write-Host "Chocolatey found in PATH, skipping install..."
    Exit
}

# Add to system PATH
$systemPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
$systemPath += ';' + $chocoExePath
[Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)

# Update local process' path
$userPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
if ($userPath) {
    $env:Path = $systemPath + ";" + $userPath
}
else {
    $env:Path = $systemPath
}

# Run the installer
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Turn off confirmation
choco feature enable -n allowGlobalConfirmation

# https://github.com/chocolatey/choco/issues/89
# Remove some of the command aliases, like `cpack` #89
Remove-Item -Path $env:ChocolateyInstall\bin\cpack.exe -Force