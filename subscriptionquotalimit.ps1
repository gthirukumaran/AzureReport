function Get-AzureQuotaLimit {
    [cmdletbinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Azure location", ValueFromPipeline = $false)] 
        $Location,
        [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Percentage usage limit", ValueFromPipeline = $false)]
        [ValidateRange(1, 99)] 
        [int]$PercentageUsageLimit,
        [Parameter(Position = 2, Mandatory = $true, HelpMessage = "Check Storage usage", ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false, $true)]
        $CheckStorageUsage,
        [Parameter(Position = 3, Mandatory = $true, HelpMessage = "Check VM resources usage", ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false, $true)]
        $CheckVMResourcesUsage,
        [Parameter(Position = 4, Mandatory = $true, HelpMessage = "Check network resources usage", ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false, $true)]
        $CheckNetworkResourcesUsage
 
    )
    begin {
        If (!(Get-AzureRmContext)) {
            Write-Host "Please login to your Azure account"
            Login-AzureRmAccount
        }
 
        $AllAvailableLocations = (Get-AzureRmLocation).Location
 
        if ($AllAvailableLocations -notcontains $Location) {
            Write-Error "Provided location name is not proper name of the available locations. Use one of the location from below list $AllAvailableLocations"
            break
        }
    }
    process {
        if ($CheckStorageUsage -eq $true) {
 
            $StorageUsageArray = @()
            $StorageUsage = Get-AzureRmStorageUsage
            $StorageUsageLimit = $StorageUsage.Limit
            $StorageUsageCurrentStatus = $StorageUsage.CurrentValue
            $StoragePercentageUsage = [Math]::Round(($StorageUsageCurrentStatus / $StorageUsageLimit) * 100)
            $Properties = @{
                "Resource Name"      = $StorageUsage.Name
                "Percentage of usage" = $StoragePercentageUsage
            }
    
            $StorageUsageObject = New-Object PSObject -Property $Properties
            $StorageUsageArray += $StorageUsageObject
        }
 
        if ($CheckVMResourcesUsage -eq $true) {
            $VMUsageOverQuota = @()
            $VMUsageBelowQuota = @()
            $VMUsage = Get-AzureRmVMUsage -Location $Location
            foreach ($VMResource in $VMUsage) {
                $ResourceName = $VMResource.Name.LocalizedValue
                $ResourceUsageLimit = $VMResource.Limit
                $ResouceUsageCurrentStatus = $VMResource.CurrentValue
                if ($ResourceUsageLimit -ne 0) {
                    $ResourcePercentageUsage = [Math]::Round(($ResouceUsageCurrentStatus / $ResourceUsageLimit) * 100)
                    if ($ResourcePercentageUsage -gt $PercentageUsageLimit) {
                        $Properties = @{
                            "Resource Name"      = $ResourceName
                            "Percentage of usage" = $ResourcePercentageUsage
                        }
                
                        $ResourceUsageOverQuota = New-Object PSObject -Property $Properties
                        $VMUsageOverQuota += $ResourceUsageOverQuota
                    }
                    else {
                        $Properties = @{
                            "Resource Name"      = $ResourceName
                            "Percentage of usage" = $ResourcePercentageUsage
                        }
                
                        $ResourceUsageOverQuota = New-Object PSObject -Property $Properties
                        $VMUsageBelowQuota += $ResourceUsageOverQuota
                    }
                }
            }
        }
     
        if ($CheckStorageUsage -eq $true) {
            $NetworkUsageOverQuota = @()
            $NetworkUsageBelowQuota = @()
            $NetworkUsage = Get-AzureRMNetworkUsage -Location $Location
            foreach ($NetworkResource in $NetworkUsage) {
                $ResourceName = $NetworkResource.Name.LocalizedValue
                $ResourceUsageLimit = $NetworkResource.Limit
                $ResouceUsageCurrentStatus = $NetworkResource.CurrentValue
                if ($ResourceUsageLimit -ne 0) {
                    $ResourcePercentageUsage = [Math]::Round(($ResouceUsageCurrentStatus / $ResourceUsageLimit) * 100)
                    if ($ResourcePercentageUsage -gt $PercentageUsageLimit) {
                        $Properties = @{
                            "Resource Name"      = $ResourceName
                            "Percentage of usage" = $ResourcePercentageUsage
                        }
                
                        $ResourceUsageOverQuota = New-Object PSObject -Property $Properties
                        $NetworkUsageOverQuota += $ResourceUsageOverQuota
                    }
                    else {
                        $Properties = @{
                            "Resource Name"      = $ResourceName
                            "Percentage of usage" = $ResourcePercentageUsage
                        }
                
                        $ResourceUsageOverQuota = New-Object PSObject -Property $Properties
                        $NetworkUsageBelowQuota += $ResourceUsageOverQuota
                    }
                }
            }    
        }
    }
 
    end {
        if ($StoragePercentageUsage -gt $PercentageUsageLimit) {
            Write-Host "Storage usage over quota limit" -ForegroundColor Red
            foreach($stgusage in $StorageUsageArray){
                [console]::ForegroundColor="red"; $_;
             
            }
            $StorageUsageArray | Format-Table
        }
        else{
            Write-Host "Storage usage below quota limit" -ForegroundColor Green
            foreach($stgusage in $StorageUsageArray){
                [console]::ForegroundColor="green"; $_;
             
            }
            $StorageUsageArray | Format-Table
        }
         
 
        Write-Host "VM usage over quota limit" -ForegroundColor Red
        foreach($vmusage in $VMUsageOverQuota){
            [console]::ForegroundColor="red"; $_;
         
        }
        $VMUsageOverQuota | Format-Table
 
        Write-Host "VM usage over below quota limit" -ForegroundColor Green
        foreach($vmusage in $VMUsageBelowQuota){
            [console]::ForegroundColor="green"; $_;
         
        }
        $VMUsageBelowQuota | Format-Table
 
        Write-Host "Network usage over quota limit" -ForegroundColor Red 
        foreach($networkusage in $NetworkUsageOverQuota){
            [console]::ForegroundColor="red"; $_;
         
        }
        $NetworkUsageOverQuota | Format-Table
        Write-Host "Network usage below quota limit" -ForegroundColor Green
        foreach($networkusage in $NetworkUsageBelowQuota){
            [console]::ForegroundColor="green"; $_;
         
        }
        $NetworkUsageBelowQuota | Format-Table
    }
}
