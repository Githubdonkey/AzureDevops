################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

$process = 1
$secondTry = 0

function Install()
{
    Write-Host "Install blah blah"
    Start-Sleep -s 2
}

Install

If ($process -eq 0) {Write-Host "Successfully Installed $process"}
ElseIf ($process -eq 3010) {Write-Host "Reboot Needed"}
ElseIf ($process -eq 1618) {
    Write-Host "Previous install didn't complete: exit code $process"
    Write-Host "Waiting 10 seconds before retry"
    Start-Sleep -s 2
    If ($secondTry -eq 1) {exit 1}
    $secondTry = 1
    Install
}
else {
    Write-Host "Install failed with exit code $process"
    Write-Host $process
    exit 1
}