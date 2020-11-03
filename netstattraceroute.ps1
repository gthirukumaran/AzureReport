#===========================================================================
# Server list
$Servers = Get-Content "c:\users\$env:username\desktop\input.txt"
   
# Define empty array
$Results = @()
  
# Looping each server and adding objects to array
$Results = Invoke-Command -cn $Servers {
  
            # URLs
            $URLs = "http://test1.powershellbros.com",
                    "http://test2.powershellbros.com",
                    "http://test3.powershellbros.com"
  
            # Creating new object
            $Object = New-Object PSCustomObject
            $Object | Add-Member -MemberType NoteProperty -Name "Servername" -Value $env:computername
            $Object | Add-Member -MemberType NoteProperty -Name "Netstat" -Value $(netstat -an)
  
            # Looping each URL
            Foreach ($URL in $URLs){
                $ObjectProp = (($URL -split "\//")[1]).trim()
                $Trace = Test-NetConnection $ObjectProp -traceroute
                $Object | Add-Member -MemberType NoteProperty -Name $($ObjectProp) -Value $Trace -Force
            }
            # Adding object to array
            $Object
  
} | select * -ExcludeProperty runspaceid, pscomputername,PSShowComputerName
  
#===========================================================================
 
# Paths for netstat and traceroute results
$NetStatPath = "c:\users\$env:username\desktop\netstat\"
$TracePath   = "c:\users\$env:username\desktop\traceroute\"
  
# Creating folders
$NetFolder   = Test-Path $NetStatPath; if ( -not $NetFolder)   { New-Item $NetStatPath -type Directory }
$TraceFolder = Test-Path $TracePath; if ( -not $TraceFolder) { New-Item $TracePath -type Directory }
 
# Saving results to txt files
foreach ($Item in $Results) {
     
    #Getting all properties from object
    $Properties = ($item | Get-Member -MemberType Properties).name | where {$_ -ne "Servername"}
     
    # Looping each property
    Foreach ($p in $Properties) {
        If($p -notmatch "netstat"){
            $Path = $TracePath + "$($item.Servername)" + "_$($p)" + "_Traceroute.txt"
            $item.$p | Out-File $Path -Force
        }
        Else{
            $Path = $NetStatPath + "$($item.Servername)" + "_NetStat.txt"
            $Item.$p | Out-File $Path -Force
        }
    }
}
