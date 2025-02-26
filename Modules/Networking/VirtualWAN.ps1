﻿<#
.Synopsis
Inventory for Azure Virtual WAN

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualwans and  resource provider in $Resources variable. 
Excel Sheet Name: VirtualWAN

.Link
https://github.com/microsoft/ARI/Modules/Networking/VirtualWAN.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 
If ($Task -eq 'Processing') {

    $VirtualWAN = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualwans' }
    $VirtualHub = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualhubs' }
    $VPNSite = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/vpnsites' }
    #$ERSite = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/expressroutegateways'}

    if($VirtualWAN)
        {
            $tmp = @()

            foreach ($1 in $VirtualWAN) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $vhub = $VirtualHub | Where-Object { $_.ID -in $data.virtualHubs.id }
                $vpn = $VPNSite | Where-Object { $_.ID -in $data.vpnSites.id }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if($vpn)
                    {
                        foreach ($2 in $vhub) {
                            foreach ($3 in $vpn) {                        
                                    foreach ($Tag in $Tags) {  
                                        $obj = @{
                                            'ID'                                 = $1.id;
                                            'Subscription'                       = $sub1.Name;
                                            'ResourceGroup'                     = $1.RESOURCEGROUP;
                                            'Name'                               = $1.NAME;
                                            'Location'                           = $1.LOCATION;
                                            'AllowBranchToBranchTraffic'       = $data.allowBranchToBranchTraffic;
                                            'AllowVnetToVnetTraffic'           = $data.allowVnetToVnetTraffic;
                                            'DisableVpnEncryption'             = $data.disableVpnEncryption;
                                            'HUBName'                           = [string]$2.name;
                                            'HUBLocation'                       = [string]$2.location;
                                            'HUBAddressPrefix'                 = [string]$2.properties.addressPrefix;
                                            'HUBGatewayPreference'             = [string]$2.properties.preferredRoutingGateway;
                                            'HUBRouterASN'                     = [string]$2.properties.virtualRouterAsn;
                                            'HUBRouterIPs'                     = [string]($2.properties.virtualRouterIps | Select-Object -Unique);
                                            'VirtualSiteName'                  = [string]$3.name;
                                            'DeviceVendor'                      = [string]$3.properties.deviceProperties.deviceVendor;
                                            'DeviceVendorIpAddress'            = [string]$3.properties.vpnSiteLinks.properties.ipAddress;
                                            'LinkProvidername'                 = [string]$3.properties.vpnSiteLinks.properties.linkProperties.linkProviderName;
                                            'LinkSpeedinMbps'                 = [string]$3.properties.vpnSiteLinks.properties.linkProperties.linkSpeedInMbps;
                                            'VirtualSitePrivateAddressSpace' = [string]$3.properties.addressSpace.addressPrefixes;
                                            'ResourceU'                         = $ResUCount;
                                            'TagName'                           = [string]$Tag.Name;
                                            'TagValue'                          = [string]$Tag.Value;
                                            'Time'                 = $ExtractionRunTime
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                    }                       
                            }
                        }
                    }
                else
                    {
                        foreach ($2 in $vhub) {                    
                                    foreach ($Tag in $Tags) {  
                                        $obj = @{
                                            'ID'                                 = $1.id;
                                            'Subscription'                       = $sub1.Name;
                                            'ResourceGroup'                     = $1.RESOURCEGROUP;
                                            'Name'                               = $1.NAME;
                                            'Location'                           = $1.LOCATION;
                                            'AllowBranchToBranchTraffic'       = $data.allowBranchToBranchTraffic;
                                            'AllowVnetToVnetTraffic'           = $data.allowVnetToVnetTraffic;
                                            'DisableVpnEncryption'             = $data.disableVpnEncryption;
                                            'HUBName'                           = [string]$2.name;
                                            'HUBLocation'                       = [string]$2.location;
                                            'HUBAddressPrefix'                 = [string]$2.properties.addressPrefix;
                                            'HUBGatewayPreference'             = [string]$2.properties.preferredRoutingGateway;
                                            'HUBRouterASN'                     = [string]$2.properties.virtualRouterAsn;
                                            'HUBRouterIPs'                     = [string]($2.properties.virtualRouterIps | Select-Object -Unique);
                                            'VirtualSiteName'                  = $null;
                                            'DeviceVendor'                      = $null;
                                            'DeviceVendorIpAddress'            = $null;
                                            'LinkProvidername'                 = $null;
                                            'LinkSpeedinMbps'                 = $null;
                                            'VirtualSitePrivateAddressSpace' = $null;
                                            'ResourceU'                         = $ResUCount;
                                            'TagName'                           = [string]$Tag.Name;
                                            'TagValue'                          = [string]$Tag.Value;
                                            'Time'                 = $ExtractionRunTime
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                    }                       
                            }
                    }
            }
            $tmp
            DataSource-Management -TableName $ModName -tmp $tmp 
        }
}
Else {
    if ($SmaResources.VirtualWAN) {

        $TableName = ('VWANTable_'+($SmaResources.VirtualWAN.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')                              
        $Exc.Add('Location')                          
        $Exc.Add('Allow BranchToBranch Traffic')        
        $Exc.Add('Allow VnetToVnet Traffic')            
        $Exc.Add('Disable Vpn Encryption')              
        $Exc.Add('HUB Name')                          
        $Exc.Add('HUB Location')                      
        $Exc.Add('HUB Address Prefix')                
        $Exc.Add('HUB Gateway Preference')            
        $Exc.Add('HUB Router ASN')                   
        $Exc.Add('HUB Router IPs')                   
        $Exc.Add('Virtual Site Name')                 
        $Exc.Add('Device Vendor')                     
        $Exc.Add('Device Vendor IpAddress')           
        $Exc.Add('Link Provider name')                
        $Exc.Add('Link Speed in Mbps')                
        $Exc.Add('Virtual Site Private Address Space') 
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VirtualWAN 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Virtual WAN' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style
    
    }
}