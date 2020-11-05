function Get-AzureVNETPrivateIPs {
 
    Param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Vnet name", ValueFromPipeline = $false)] 
        $Vnet,
        [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Resource group name", ValueFromPipeline = $false)] 
        $ResourceGroupName
    )
               
    If (!(Get-AzureRmContext)) {
        Write-Host "Please login to your Azure account"
        Login-AzureRmAccount
    }
    Try {
        $Subnets = (Get-AzureRmVirtualNetwork -Name $Vnet -ResourceGroupName $ResourceGroupName).SubnetsText 
    }
    Catch {
        Write-Error "VNET $Vnet can not be found!"
        break
    }
 
    $Subnets = $Subnets | ConvertFrom-Json
    foreach ($subnet in $subnets) {
        if ($subnet.IpConfigurations -ne $null) {
            $NotAvailableIPs = @()
            foreach ($ipconfig in $subnet.IpConfigurations) {
                $RG = $ipconfig.Id.Split("/")[4]
                $NIC = $ipconfig.Id.Split("/")[8]
                $IP = (Get-AzureRmNetworkInterface -Name $NIC -ResourceGroupName $RG).IpConfigurations.PrivateIpAddress
                $NotAvailableIPs += $IP
            }
            $SubnetName = $subnet.Name
            $AddressPrefix = $subnet.AddressPrefix
            $IPsUsed = $NotAvailableIPs.Count
            Write-Host "Subnet $subnetname ($AddressPrefix) have $IPsUsed IPs which are already used:"
            foreach ($NotAvailableIP in $NotAvailableIPs) {
                Write-Host $NotAvailableIP
            }
            Write-Host "-----------------------------------"
        }
 
    }
}
