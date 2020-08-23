# $computers = Import-Csv “C:\Users\tom\Desktop\repo\CI\computerlist.csv”
# https://devblogs.microsoft.com/scripting/use-powershell-to-quickly-find-installed-software/

$computers = $Env:Computername

$array = @()

$Header = @"
<b>$computers</b>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$Title = @"
<div style='margin:  0px auto; BACKGROUND-COLOR:Black;Color:White;font-weight:bold;FONT-SIZE:  16pt;TEXT-ALIGN: center;'>
$Env:Computername  Services Report
</div>
"@

$test = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<b>$Env:Computername</b>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
table {border:1px solid black;margin-left:auto;margin-right:auto;}
</style>
</head><body>
<div style='margin:  0px auto; BACKGROUND-COLOR:Black;Color:White;font-weight:bold;FONT-SIZE:  16pt;TEXT-ALIGN: center;'>
$Env:Computername  Services Report
<BR><i>Report generated on $((Get-Date).ToString()) from $($Env:Computername)</i>
</div>  
"@

foreach($pc in $computers){

    $computername=$pc.computername
    #Define the variable to hold the location of Currently Installed Programs
    $UninstallKey=”SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall” 
    #Create an instance of the Registry Object and open the HKLM base key
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computername) 
    #Drill down into the Uninstall key using the OpenSubKey Method
    $regkey=$reg.OpenSubKey($UninstallKey) 
    #Retrieve an array of string that contain all the subkey names
    $subkeys=$regkey.GetSubKeyNames() 
    #Open each Subkey and use GetValue Method to return the required values for each

    foreach($key in $subkeys){
        $thisKey=$UninstallKey+”\\”+$key 
        $thisSubKey=$reg.OpenSubKey($thisKey) 
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name “ComputerName” -Value $computername
        $obj | Add-Member -MemberType NoteProperty -Name “DisplayName” -Value $($thisSubKey.GetValue(“DisplayName”))
        $obj | Add-Member -MemberType NoteProperty -Name “DisplayVersion” -Value $($thisSubKey.GetValue(“DisplayVersion”))
        $obj | Add-Member -MemberType NoteProperty -Name “InstallLocation” -Value $($thisSubKey.GetValue(“InstallLocation”))
        $obj | Add-Member -MemberType NoteProperty -Name “Publisher” -Value $($thisSubKey.GetValue(“Publisher”))
        $array += $obj

    } 

}
$post = "<BR><i>Report generated on $((Get-Date).ToString()) from $($Env:Computername)</i>"

$array | Where-Object { $_.DisplayName } | select DisplayName, DisplayVersion, Publisher | ConvertTo-Html -PreContent $test -Fragment | Out-File aliases.html
# Get-HotFix | select HotFixID, InstalledOn, Title | ConvertTo-Html -PreContent $Title -PostContent $post -Fragment | Out-File -Append aliases.html

$wu = new-object -com “Microsoft.Update.Searcher”
$totalupdates = $wu.GetTotalHistoryCount()
$all = $wu.QueryHistory(0,$totalupdates)
# Define a new array to gather output
$OutputCollection=  @()
Foreach ($update in $all)
    {
    $string = $update.title
    $Regex = “KB\d*”
    $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }
     $output = New-Object -TypeName PSobject
     $output | add-member NoteProperty “HotFixID” -value $KB.‘ $_.Matches ‘.Value
     $output | add-member NoteProperty “Title” -value $string
     $OutputCollection += $output
     }

# Oupput the collection sorted and formatted:
#$OutputCollection | Sort-Object HotFixID | Format-Table -AutoSize
$OutputCollection | Sort-Object HotFixID | ConvertTo-Html -PreContent $test -Fragment | Out-File -Append aliases.html
Write-Host “$($OutputCollection.Count) Updates Found”

Invoke-Item aliases.html