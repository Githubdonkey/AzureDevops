# Set TLS1.2
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
#Install-WindowsFeature -Name NET-Framework-Features -IncludeAllSubFeature
Write-Host "Install-WindowsFeature -Name NET-Framework-45-Features"
#Install-WindowsFeature -Name NET-Framework-45-Features -IncludeAllSubFeature
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