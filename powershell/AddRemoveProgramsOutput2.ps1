$Services = Get-Service | Select Name, DisplayName, Status, @{L='RequiredServices';E={$_.RequiredServices  -join '; '}}
$Report = 'ServicesReport.html'
$pre = @"
<div style='margin:  0px auto; BACKGROUND-COLOR:Black;Color:White;font-weight:bold;FONT-SIZE:  16pt;TEXT-ALIGN: center;'>
$Env:Computername  Services Report
</div>    
"@ 
$post = "<BR><i>Report generated on $((Get-Date).ToString()) from $($Env:Computername)</i>"
$Services | ConvertTo-HTML -PreContent  $pre -PostContent  $post |  Out-file $Report
Invoke-Item $Report