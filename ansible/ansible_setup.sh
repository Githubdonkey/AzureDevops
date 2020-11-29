#!/bin/bash

packerProvider=$1
#packerOs=$2
#packerImage=$3
#packerVarFileType=$4

echo $packerProvider

#if test -z "$packerImage" 
#then
#      echo "\$packerImage is empty"
#      exit 0
#else
#      echo "\$packerImage is NOT empty"
#fi

ansibleHosts="/etc/ansible/hosts"
[ -f $ansibleHosts ] && rm $ansibleHosts
touch $ansibleHosts

cat <<EOF > /etc/ansible/hosts
[windows]
10.1.1.5

[windows:vars]
 ansible_user=localadm
 ansible_password=thisPassChange@End
 ansible_port=5986
 ansible_connection=winrm
 ansible_winrm_server_cert_validation=ignore
 ansible_winrm_transport=credssp
EOF

#ansibleWindows="/etc/ansible/group_vars/windows.yaml"
#[ ! -e "/etc/ansible/group_vars" ] && mkdir "/etc/ansible/group_vars"
#ansibleWindows="/etc/ansible/group_vars/windows.yaml"
#[ -f $ansibleWindows ] && rm $ansibleWindows
#touch $ansibleWindows

#cat <<EOF > /etc/ansible/group_vars/windows.yaml
#ansible_user: localadm
#ansible_password: thisPassChange@End
#ansible_connection: winrm
#ansible_winrm_transport: basic
#ansible_winrm_port: 5985
#ansible_winrm_server_cert_validation: ignore
#EOF