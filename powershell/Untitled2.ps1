################################################################################
##  File:  Install-PowershellCore.ps1
##  Team:  CI-Platform
##  Desc:  Install PowerShell Core
################################################################################

# https://devblogs.microsoft.com/scripting/use-powershell-to-quickly-find-installed-software/

$arrayPrograms = @()
$arrayUpdates = @()
$arrayDotnet = @()

$Title = @"
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

$TitlePrograms = @"
<div>Installed Programs</div>
"@

$TitleUpdates = @"
<div>Updates Installed</div>
"@

$TitleDotnet = @"
<div>DotNet Versions installed</div>
"@

$main = @"
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
$Env:Computername  Services Report
<BR><i>Report generated on $((Get-Date).ToString())</i>
</div>
<BR>
<div>Installed Programs</div>
"@

$post = "</body></html>"

# Check for Installed Programs
$installedPrograms = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

foreach($program in $installedPrograms){
    $prg = New-Object PSObject
    $prg | Add-Member -MemberType NoteProperty 'DisplayName' -Value $program.GetValue('DisplayName')
    $prg | Add-Member -MemberType NoteProperty 'DisplayVersion' -Value $program.GetValue('DisplayVersion')
    $prg | Add-Member -MemberType NoteProperty 'Publisher' -Value $program.GetValue('Publisher')
    $arrayPrograms += $prg
}

# Check for Windows Update
$installedUpdates = Get-HotFix

foreach($update in $installedUpdates){
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty 'HotFixID' -Value $update.hotfixid
    $obj | Add-Member -MemberType NoteProperty 'InstalledOn' -Value $update.installedon
    $obj | Add-Member -MemberType NoteProperty 'Description' -Value $update.description
    $arrayUpdates += $obj
}

$Title | Out-File C:\image\aliases.html

$arrayPrograms | Where-Object { $_.DisplayName } | Sort-Object DisplayName | ConvertTo-Html -PreContent $TitlePrograms -Fragment | Out-File -Append C:\image\aliases.html
$arrayUpdates | Sort-Object HotFixID | ConvertTo-Html -PreContent $TitleUpdates -Fragment | Out-File -Append C:\image\aliases.html
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version, Release -ErrorAction 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | Select-Object PSChildName, Version, Release | ConvertTo-Html -PreContent $TitleDotnet -PostContent $post -Fragment | Out-File -Append C:\image\aliases.html

#$Title | ConvertTo-Html | Out-File C:\image\aliases.html

#$Title | Out-File C:\image\aliases.html

#Add-Content 'C:\image\aliases.html' $Title

Invoke-Item C:\image\aliases.html