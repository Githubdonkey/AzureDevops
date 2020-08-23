
$array = @()

#$all = Get-WmiObject -Class Win32_Product

#Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

#Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | Select-Object DisplayName

#(Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall")[0] | Get-Member

$tmp = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
#$tmp[1].GetValue('DisplayName')

foreach($reg in $tmp){
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name “DisplayName” -Value $($reg.GetValue(“DisplayName”))
    $obj | Add-Member -MemberType NoteProperty -Name “DisplayVersion” -Value $($reg.GetValue(“DisplayVersion”))
    $obj | Add-Member -MemberType NoteProperty -Name “Publisher” -Value $($reg.GetValue(“Publisher”))
    $array += $obj
    #$reg.GetValue('DisplayName')
    #$reg.GetValue('DisplayVersion')
    #$reg.GetValue('Publisher')
}

$array | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher | ConvertTo-Html -PreContent $main -Fragment | Out-File C:\image\aliases.html

#Write-Host $tmp[1].GetValue('DisplayName')

#$array | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher | ConvertTo-Html -PreContent $main -Fragment | Out-File C:\image\aliases.html
Invoke-Item C:\image\aliases.html