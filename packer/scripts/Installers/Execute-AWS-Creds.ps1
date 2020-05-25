
if (Test-Path "$env:USERPROFILE\.aws\config") {Remove-Item "$env:USERPROFILE\.aws\config"}
#Add-Content -Path "$env:USERPROFILE\.aws\config" -Value '[default]'
#Add-Content -Path "$env:USERPROFILE\.aws\config" -Value "region = $env:USERNAME"
#Add-Content -Path "$env:USERPROFILE\.aws\config" -Value 'output=json'

if (Test-Path "$env:USERPROFILE\.aws\credentials") {Remove-Item "$env:USERPROFILE\.aws\credentials"}
#Add-Content -Path "$env:USERPROFILE\.aws\credentials" -Value '[default]'
#Add-Content -Path "$env:USERPROFILE\.aws\credentials" -Value "aws_access_key_id = $env:USERNAME"
#Add-Content -Path "$env:USERPROFILE\.aws\credentials" -Value "aws_secret_access_key = $env:USERNAME"

aws configure set aws_access_key_id $env:aws_access_key
aws configure set aws_secret_access_key $env:aws_secret_key
aws configure set default.region $env:region