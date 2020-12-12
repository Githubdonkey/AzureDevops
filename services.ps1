aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/name" --value "${packerImageName}" --type String --overwrite
aws ssm put-parameter --name "/builds/${packerProvider}/${packerOs}/${packerImage}/id" --value "${packerImageId}" --type String --overwrite

aws ssm get-parameter --name "/services/KcStandAlone" --query "Parameters[*].{Name:Name,Values:StringList}" --output text

function vmStart($job) {
    if ($job -eq "VM running"){$task = "start"}
    if ($job -eq "VM stopped"){$task = "stop"}
    Get-Content .\computers.txt | ForEach-Object {
    $vmName = $_
    $currentState = (az vm show -g "AnsibleVM" -n $vmName -d --query 'powerState')
    if ($currentState -ne $job){az vm $task -g $resourceGroup -n $vmName | Out-Null}
    while ($currentState -ne $job){
            if ($currentState -ne $job){write-host $vmName "under" $resourceGroup "is" $currentState}
            Start-Sleep -Seconds 5
            $currentState = (az vm show -g "AnsibleVM" -n $vmName -d --query 'powerState' -o tsv)
            Write-Output $currentState
        }
}

}

vmStart "VM running"

Write-Output "s3://gitdonkey/devops/${packerImageName}.html"
aws s3 cp aliases.html "s3://gitdonkey/devops/${packerImageName}.html"
Write-Output "s3://gitdonkey/devops/${packerImageName}.json"
aws s3 cp manifest.json "s3://gitdonkey/devops/${packerImageName}.json"
Write-Output "s3://gitdonkey/devops/${packerImageName}_packer_log.json"
aws s3 cp packer.log "s3://gitdonkey/devops/${packerImageName}_packer_log.json"

#Write-Host "Setup PowerShellGet"
# Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-Module -Name PowerShellGet -Force
#Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

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