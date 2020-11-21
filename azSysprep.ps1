$vmName = "template-test-vm"
$rgName = "myResourceGroup"
$location = "EastUS"
$imageName = "myNewImage"

Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

$image = New-AzImageConfig -Location $location -SourceVirtualMachineId $vm.Id

New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $rgName

New-AzVm `
    -ResourceGroupName "myResourceGroup" `
    -Name "myVMfromImage" `
	-ImageName "tempaltetest-image-deploy2" `
    -Location "East US" `
    -VirtualNetworkName "myImageVnet" `
    -SubnetName "myImageSubnet" `
    -SecurityGroupName "myImageNSG" `
    -PublicIpAddressName "myImagePIP" `
    -OpenPorts 3389

    <#
    open cmd
    rmdir C:\Windows\Panther /s /q
    %windir%\system32\sysprep\sysprep.exe
    Select OOBE & Generalize & Shutdown

    Capture
    Name: test4-image-20201004154834
    RG: myResourceGroup
    virtual machine name: test4


    #>