#CSS codes
$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    


    #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }



    .StopStatus {

        color: #ff0000;
    }
    
  
    .RunningStatus {

        color: #008000;
    }




</style>
"@

#The command below will get the name of the computer
$ComputerName = "<h1>Computer name: $env:computername</h1>"

#The command below will get the Operating System information, convert the result to HTML code as table and store it to a variable
$OSinfo = Get-CimInstance -Class Win32_OperatingSystem | ConvertTo-Html -As List -Property Version,Caption,BuildNumber,Manufacturer -Fragment -PreContent "<h2>Operating System Information</h2>"

#The command below will get the Processor information, convert the result to HTML code as table and store it to a variable
$ProcessInfo = Get-CimInstance -ClassName Win32_Processor | ConvertTo-Html -As List -Property DeviceID,Name,Caption,MaxClockSpeed,SocketDesignation,Manufacturer -Fragment -PreContent "<h2>Processor Information</h2>"

#The command below will get the BIOS information, convert the result to HTML code as table and store it to a variable
$BiosInfo = Get-CimInstance -ClassName Win32_BIOS | ConvertTo-Html -As List -Property SMBIOSBIOSVersion,Manufacturer,Name,SerialNumber -Fragment -PreContent "<h2>BIOS Information</h2>"

#The command below will get the details of Disk, convert the result to HTML code as table and store it to a variable
$DiscInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | ConvertTo-Html -As List -Property DeviceID,DriveType,ProviderName,VolumeName,Size,FreeSpace -Fragment -PreContent "<h2>Disk Information</h2>"

$InstalledPrograms = Get-CimInstance -Class Win32_Product | select Name, Version | ConvertTo-Html -As List -Property Name,Version -Fragment -PreContent "<h2>Installed Software</h2>"

$InstalledUpdates = Get-HotFix | ConvertTo-Html -As List -Property HotFixID,Description,InstalledOn -Fragment -PreContent "<h2>Installed Updates</h2>"

$DotnetVersions = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version, Release -ErrorAction 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | ConvertTo-Html -As List -Property PSChildName, Version -Fragment -PreContent "<h2>DotNet Versions</h2>"

$EnvVariables = Get-CimInstance Win32_Environment | select Name, VariableValue | ConvertTo-Html -As List -Property Name,VariableValue -Fragment -PreContent "<h2>Env Variables</h2>"

#The command below will get first 10 services information, convert the result to HTML code as table and store it to a variable
$ServicesInfo = Get-CimInstance -ClassName Win32_Service | Select-Object  | ConvertTo-Html -Property Name,DisplayName,State -Fragment -PreContent "<h2>Services Information</h2>"
$ServicesInfo = $ServicesInfo -replace '<td>Running</td>','<td class="RunningStatus">Running</td>'
$ServicesInfo = $ServicesInfo -replace '<td>Stopped</td>','<td class="StopStatus">Stopped</td>'

  
#The command below will combine all the information gathered into a single HTML report
$Report = ConvertTo-HTML -Body "$ComputerName $OSinfo $ProcessInfo $BiosInfo $DiscInfo $InstalledPrograms $InstalledUpdates $EnvVariables $DotnetVersions $ServicesInfo" -Head $header -Title "Computer Information Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p>"

#The command below will generate the report to an HTML file
$Report | Out-File .\Basic-Computer-Information-Report.html

Invoke-Item Basic-Computer-Information-Report.html

#$UninstallKeys = @(
#                    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
#                    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
#                )

#Get-WmiObject -Class Win32_Product | select Name, Version
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version, Release -ErrorAction 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | Select-Object PSChildName, Version, Release