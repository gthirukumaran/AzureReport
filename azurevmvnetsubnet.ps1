$reportName = "C:\temp\AzVMIPs.csv"
Get-AzurermSubscription | Select-AzurermSubscription | ForEach-Object {$_ 
$report = @()

$vms = Get-AzurermVM
$publicIps = Get-AzurermPublicIpAddress 
$nics = Get-AzurermNetworkInterface | ?{ $_.VirtualMachine -NE $null}
foreach ($nic in $nics) { 
    $info = "" | Select-Object VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, SubscriptionName 
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $info.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $info.OsType = $vm.StorageProfile.OsDisk.OsType 
        $info.VMName = $vm.Name
        $info.ResourceGroupName = $vm.ResourceGroupName 
        $info.Region = $vm.Location 
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress
        $info.SubscriptionName = (Get-AzContext).Name
        $report+=$info
        } 
        
$report | Export-CSV "C:\temp\1.CSV" -NoTypeInformation -Append
}
