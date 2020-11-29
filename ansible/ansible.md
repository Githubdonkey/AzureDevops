Create SErvice principal
az ad sp create-for-rbac --name ansibleSP
az account show


ssh -i <private key path> ansible@20.55.100.236

mkdir ~/.azure
vi ~/.azure/credentials

[default]
subscription_id=<your-Azure-subscription_id>
client_id=<azure service-principal-appid>
secret=<azure service-principal-password>
tenant=<azure serviceprincipal-tenant>



Ansible is an agentless architecture based automation tool . Only it needs ssh authentication using Ansible Control Machine private/public key pair. Now let us create a pair of private and public keys. Run the following command to generate a private/public key pair for ssh and to install the public key in the local machine.

ssh-keygen -t rsa

chmod 755 ~/.ssh

touch ~/.ssh/authorized_keys

chmod 644 ~/.ssh/authorized_keys

ssh-copy-id ansible@127.0.0.1



sudo apt-get update
sudo apt-get install ansible -y
sudo apt-get install python-pip -y
pip install pywinrm

windows system https://adamtheautomator.com/winrm-https-ansible/ https://www.ansible.com/blog/connecting-to-a-windows-host
Set-Service -Name "WinRM" -StartupType Automatic
Start-Service -Name "WinRM"

if (-not (Get-PSSessionConfiguration) -or (-not (Get-ChildItem WSMan:\localhost\Listener))) {
    ## Use SkipNetworkProfileCheck to make available even on Windows Firewall public profiles
    ## Use Force to not be prompted if we're sure or not.
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
}

#region Enable cert-based auth
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
#endregion

## This is the public key generated from the Ansible server using:
cat > openssl.conf << EOL
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req_client]
extendedKeyUsage = clientAuth
subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:localadm@localhost
EOL
export OPENSSL_CONF=openssl.conf
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out cert.pem -outform PEM -keyout cert_key.pem -subj "/CN=localadm" -extensions v3_req_client
rm openssl.conf 

$pubKeyFilePath = 'C:\certs\cert.pem'

## Import the public key into Trusted Root Certification Authorities and Trusted People
$null = Import-Certificate -FilePath $pubKeyFilePath -CertStoreLocation 'Cert:\LocalMachine\Root'
$null = Import-Certificate -FilePath $pubKeyFilePath -CertStoreLocation 'Cert:\LocalMachine\TrustedPeople'

$hostname = hostname
$serverCert = New-SelfSignedCertificate -DnsName $hostName -CertStoreLocation 'Cert:\LocalMachine\My'

#---------------------------------------------------------------------------------------------------------

## Find all HTTPS listners
$httpsListeners = Get-ChildItem -Path WSMan:\localhost\Listener\ | where-object { $_.Keys -match 'Transport=HTTPS' }

## If not listeners are defined at all or no listener is configured to work with
## the server cert created, create a new one with a Subject of the computer's host name
## and bound to the server certificate.
if ((-not $httpsListeners) -or -not (@($httpsListeners).where( { $_.CertificateThumbprint -ne $serverCert.Thumbprint }))) {
    $newWsmanParams = @{
        ResourceUri = 'winrm/config/Listener'
        SelectorSet = @{ Transport = "HTTPS"; Address = "*" }
        ValueSet    = @{ Hostname = $hostName; CertificateThumbprint = $serverCert.Thumbprint }
        # UseSSL = $true
    }
    $null = New-WSManInstance @newWsmanParams
}

#---------------------------------------------------------------------------------------------------------


$testUserAccountName="localadm"
$testUserAccountPassword="thisPassChange@End"

$credential = Get-Credential
#-ArgumentList $testUserAccountName, $testUserAccountPassword

## Find the cert thumbprint for the client certificate created on the Ansible host
$ansibleCert = Get-ChildItem -Path 'Cert:\LocalMachine\Root' | Where-Object {$_.Subject -eq 'CN=localadm'}

$params = @{
	Path = 'WSMan:\localhost\ClientCertificate'
	Subject = "$testUserAccountName@localhost"
	URI = '*'
	Issuer = $ansibleCert.Thumbprint
  Credential = $credential
	Force = $true
}
New-Item @params

#------------------------------------------------------------------------------------------------------------

$newItemParams = @{
    Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Name         = 'LocalAccountTokenFilterPolicy'
    Value        = 1
    PropertyType = 'DWORD'
    Force        = $true
}
$null = New-ItemProperty @newItemParams

#------------------------------------------------------------------------------------------------------------

#region Ensure WinRM 5986 is open on the firewall
 $ruleDisplayName = 'Windows Remote Management (HTTPS-In)'
 if (-not (Get-NetFirewallRule -DisplayName $ruleDisplayName -ErrorAction Ignore)) {
     $newRuleParams = @{
         DisplayName   = $ruleDisplayName
         Direction     = 'Inbound'
         LocalPort     = 5986
         RemoteAddress = 'Any'
         Protocol      = 'TCP'
         Action        = 'Allow'
         Enabled       = 'True'
         Group         = 'Windows Remote Management'
     }
     $null = New-NetFirewallRule @newRuleParams
 }
 #endregion

#----------------------------------------------------------------------------------------------------------------
$testUserAccountName="localadm"
Get-LocalUser -Name $testUserAccountName | Add-LocalGroupMember -Group 'Administrators'




#------old working--------------------------------------------------------------------------------------------------
New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress 10.1.0.9 -Action Allow
winrm quickconfig -q
winrm quickconfig -transport:https
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}



ansible@AnsibleVM:~$ cat /etc/ansible/hosts
[windows]
10.1.0.8
[linux]
10.1.0.6
10.1.0.7
[windows:vars]
#ansible_user=localadm
#ansible_password=thisPassChange@End
#ansible_connection=winrm
#ansible_winrm_port=5986

ansible_user: localadm
ansible_password: thisPassChange@End
ansible_connection: winrm
ansible_winrm_transport: basic
ansible_winrm_port: 5985
ansible_winrm_server_cert_validation: ignore


ansible@AnsibleVM:~$ cat /etc/ansible/group_vars/windows.yaml
---
ansible_user: localadm
ansible_password: thisPassChange@End
ansible_connection: winrm
ansible_winrm_transport: basic
ansible_winrm_port: 5985
ansible_winrm_server_cert_validation: ignore


ansible -m win_ping windows
ansible win -i hosts -m win_ping
ansible win -m win_chocolatey -a 'name=notepadplusplus state=present'



---
- name: Installing Apache MSI
  hosts: windows

  tasks:
    - name: enable TLSv1.2 support
      win_regedit:
        path: HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\{{ item.type }}
        name: '{{ item.property }}'
        data: '{{ item.value }}'
        type: dword
        state: present
      register: enable_tls12
      loop:
      - type: Server
        property: Enabled
        value: 1
      - type: Server
        property: DisabledByDefault
        value: 0
      - type: Client
        property: Enabled
        value: 1
      - type: Client
        property: DisabledByDefault
        value: 0

    - name: reboot if TLS config was applied
      win_reboot:
      when: enable_tls12 is changed

openssl s_client -connect 10.1.0.5:5986

windows machine
firrewall 5986 allow
New-SelfSignedCertificate -DnsName ansibleclient -CertStoreLocation Cert:\LocalMachine\My

winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=”ansibleclient”; CertificateThumbprint=”F3841B00F337F381741B91279995F91C1C01371D”}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


msi.yml
---
- name: Installing Apache MSI
  hosts: windows

  tasks:

    - name: Create directory structure
      win_file:
        path: C:\ansible_examples
        state: directory

    - name: Download the Apache installer
      win_get_url:
        url: https://archive.apache.org/dist/httpd/binaries/win32/httpd-2.2.25-win32-x86-no_ssl.msi
        dest: C:\ansible_examples\httpd-2.2.25-win32-x86-no_ssl.msi

    - name: Install MSI
      win_package:
        path: C:\ansible_examples\httpd-2.2.25-win32-x86-no_ssl.msi
        state: present

    - name: Remove directory structure
      win_file:
        path: C:\ansible_examples
        state: absent

directory.yml
---
- name: Installing Apache MSI
  hosts: windows

  tasks:
    - name: Create directory structure
      win_file:
        path: C:\Temp
        state: directory

    - name: Touch a file (creates if not present, updates modification time if present)
      win_file:
        path: C:\Temp\foo.conf
        state: touch

    - name: Remove a file, if present
      win_file:
        path: C:\Temp\foo.conf
        state: absent

    - name: Remove directory structure
      win_file:
        path: C:\Temp
        state: absent

winUpdates.yml
---
- name: Installing Apache MSI
  hosts: windows

  tasks:
    - name: Install all critical and security updates
      win_updates:
        category_names:
        - CriticalUpdates
        - SecurityUpdates
        state: installed
      register: update_result

    - name: Reboot host if required
      win_reboot:
      when: update_result.reboot_required




---
- name: Installing choc vscode ps
  hosts: windows

  tasks:
    - name: Install package dependencies
      win_chocolatey:
        name:
        - chocolatey-core.extension
        - chocolatey-windowsupdate.extension
        state: present

    - name: Install VS Code and PowerShell Preview
      win_chocolatey:
        name:
        - vscode.install
        - powershell-preview
        state: present

---
- name: Installing choc vscode ps
  hosts: windows

  tasks:
    - name: Install IIS (Web-Server only)
      win_feature:
        name: Web-Server
        state: present

    - name: Install IIS (Web-Server and Web-Common-Http)
      win_feature:
        name:
        - Web-Server
        - Web-Common-Http
        state: present

    - name: Install NET-Framework-Core from file
      win_feature:
        name: NET-Framework-Core
        source: C:\Temp\iso\sources\sxs
        state: present

    - name: Install IIS Web-Server with sub features and management tools
      win_feature:
        name: Web-Server
        state: present
        include_sub_features: yes
        include_management_tools: yes
      register: win_feature

    - name: Reboot if installing Web-Server feature requires it
      win_reboot:
      when: win_feature.reboot_required









Azure VM scripts

stop-AzVM -name ""
start-AzVM
get-AzVM -name linux*

az vm get-instance-view --name vmName --resource-group resourceGroupName --query instanceView.statuses[1] --output table

$getStatus=(Get-AzVM -ResourceGroupName "ANSIBLEVM" -Name "linux-test-2" -Status).Statuses[1].DisplayStatus
Write-Host $getStatus





setup windows
New-SelfSignedCertificate -DnsName "t20201129194145" -CertStoreLocation Cert:\LocalMachine\My

winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="t20201129194145"; CertificateThumbprint="935CE1CA3AB9182533BCD631423E7D1E48F8D618"}'