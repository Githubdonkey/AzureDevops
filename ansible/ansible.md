



#----------------------------------------------Ansible Setup-----------------------------------------------
localadm@t20201129194543:~$ history
    1  sudo apt-get update
    2  sudo apt-get install ansible -y
    3  sudo apt-get install python-pip -y
    4  pip install --upgrade pip
    5  pip install "pywinrm>=0.3.0"
    6  pip install "pyOpenSSL>=17.3.0"
    7  pip install requests-credssp

ansible@AnsibleVM:~$ cat /etc/ansible/hosts
[windows]
10.1.1.5

[windows:vars]
 ansible_user=localadm
 ansible_password=<password>
 ansible_port=5986
 ansible_connection=winrm
 ansible_winrm_server_cert_validation=ignore
 ansible_winrm_transport=credssp

#----------------------------------------------Windows Ansible Client-----------------------------------------------
New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress 10.1.1.4 -Action Allow
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname=$env:COMPUTERNAME; CertificateThumbprint=$cert.thumbprint}'
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname=$env:COMPUTERNAME; CertificateThumbprint=$cert.thumbprint}'
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986
Enable-WSManCredSSP -Role Server -Force


$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
write-host $cert.thumbprint

#-----------------------------------------------Create Service principal----------------------------------------------
az ad sp create-for-rbac --name ansibleSP
az account show
mkdir ~/.azure
vi ~/.azure/credentials

[default]
subscription_id=<your-Azure-subscription_id>
client_id=<azure service-principal-appid>
secret=<azure service-principal-password>
tenant=<azure serviceprincipal-tenant>

#----------------------------------------------Ansible Commands-----------------------------------------------
ansible -m win_ping windows
ansible windows -m win_chocolatey -a 'name=notepadplusplus state=present'

```
---
- name: Installing choc vscode ps
  hosts: windows

  tasks:
    - name: Install git
      win_chocolatey:
        name: git
        state: present

    - name: Upgrade installed packages
      win_chocolatey:
        name: all
        state: latest

---
- name: TLSv1.2 support
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

---
- name: Installing winUpdates
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

```

#------old working HTTP --------------------------------------------------------------------------------------------------
New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress 10.1.0.9 -Action Allow
winrm quickconfig -q
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#----------------------------------------- Error in pipeline
```
10.1.1.5 | FAILED! => {
    "msg": "winrm or requests is not installed: No module named winrm"
}
##[error]Bash exited with code '2'.
Finishing: ansibleRun
```




#-------------------------------------------------- Testing Azure Scripts

Azure VM scripts
stop-AzVM -name ""
start-AzVM
get-AzVM -name linux*

az vm get-instance-view --name vmName --resource-group resourceGroupName --query instanceView.statuses[1] --output table

$getStatus=(Get-AzVM -ResourceGroupName "ANSIBLEVM" -Name "linux-test-2" -Status).Statuses[1].DisplayStatus
Write-Host $getStatus

