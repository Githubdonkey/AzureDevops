Write-Host "Disabling IE Protected Mode"
New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" -Name 2707 -PropertyType DWord -Value 0 -Force -Verbose

New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name 2500 -PropertyType DWord -Value 3 -Force -Verbose
New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name 2707 -PropertyType DWord -Value 0 -Force -Verbose

New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name 2500 -PropertyType DWord -Value 3 -Force -Verbose
New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name 2707 -PropertyType DWord -Value 0 -Force -Verbose

New-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4" -Name 2707 -PropertyType DWord -Value 0 -Force -Verbose