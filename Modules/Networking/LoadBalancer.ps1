<#
.Synopsis
Inventory for Azure LoadBalancer

.DESCRIPTION
This script consolidates information for all microsoft.network/loadbalancers and  resource provider in $Resources variable. 
Excel Sheet Name: LoadBalancer

.Link
https://github.com/microsoft/ARI/Modules/Networking/LoadBalancer.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported) 
If ($Task -eq 'Processing') {

    $LoadBalancer = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/loadbalancers' }

    if($LoadBalancer)
        {
            $tmp = @()

            foreach ($1 in $LoadBalancer) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if ($null -ne $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -ne $data.probes) {
                    foreach ($2 in $data.frontendIPConfigurations) {
                        $Fronttarget = ''    
                        $Frontsub = ''
                        $FrontType = ''
                        if ($null -ne $2.properties.subnet.id) {
                            $Fronttarget = $2.properties.subnet.id.split('/')[8]
                            $Frontsub = $2.properties.subnet.id.split('/')[10]
                            $FrontType = 'VNET' 
                        }
                        elseif ($null -ne $2.properties.publicIPAddress.id) {
                            $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                            $Frontsub = ''
                            $FrontType = 'Public IP' 
                        }       
                        foreach ($3 in $data.backendAddressPools) {
                            $BackTarget = ''
                            $BackType = ''
                            if ($null -ne $3.properties.backendIPConfigurations.id) {
                                $BackTarget = $3.properties.backendIPConfigurations.id.split('/')[8]
                                $BackType = $3.properties.backendIPConfigurations.id.split('/')[7]
                            }
                            foreach ($4 in $data.probes) {
                                    foreach ($Tag in $Tags) {
                                        $obj = @{
                                            'ID'                        = $1.id;
                                            'Subscription'              = $sub1.Name;
                                            'ResourceGroup'            = $1.RESOURCEGROUP;
                                            'Name'                      = $1.NAME;
                                            'Location'                  = $1.LOCATION;
                                            'SKU'                       = $1.sku.name;
                                            'FrontendName'             = $2.name;
                                            'FrontendTarget'           = $Fronttarget;
                                            'FrontendType'             = $FrontType;
                                            'FrontendSubnet'           = $frontsub;
                                            'BackendPoolName'         = $3.name;
                                            'BackendTarget'            = $BackTarget;
                                            'BackendType'              = $BackType;
                                            'ProbeName'                = $4.name;
                                            'ProbeIntervalSec'      = $4.properties.intervalInSeconds;
                                            'ProbeProtocol'            = $4.properties.protocol;
                                            'ProbePort'                = $4.properties.port;
                                            'ProbeUnhealthyThreshold' = $4.properties.numberOfProbes;
                                            'ResourceU'                = $ResUCount;
                                            'TagName'                  = [string]$Tag.Name;
                                            'TagValue'                 = [string]$Tag.Value;
                                            'Time'                 = $ExtractionRunTime
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                    }                               
                            }
                        }
                    }
                }  
                elseif ($null -ne $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -eq $data.probes) {
                    foreach ($2 in $data.frontendIPConfigurations) {
                        $Fronttarget = ''    
                        $Frontsub = ''
                        if ($null -ne $2.properties.subnet.id) {
                            $Fronttarget = $2.properties.subnet.id.split('/')[8]
                            $Frontsub = $2.properties.subnet.id.split('/')[10]
                            $FrontType = 'VNET' 
                        }
                        elseif ($null -ne $2.properties.publicIPAddress.id) {
                            $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                            $Frontsub = ''
                            $FrontType = 'Public IP' 
                        }        
                        foreach ($3 in $data.backendAddressPools) {
                            $BackTarget = ''
                            $BackType = ''
                            if ($null -ne $3.properties.backendIPConfigurations.id) {
                                $BackTarget = $3.properties.backendIPConfigurations.id.split('/')[8]
                                $BackType = $3.properties.backendIPConfigurations.id.split('/')[7]
                            }
                                foreach ($Tag in $Tags) {  
                                    $obj = @{
                                        'ID'                        = $1.id;
                                        'Subscription'              = $sub1.Name;
                                        'ResourceGroup'            = $1.RESOURCEGROUP;
                                        'Name'                      = $1.NAME;
                                        'Location'                  = $1.LOCATION;
                                        'SKU'                       = $1.sku.name;
                                        'FrontendName'             = $2.name;
                                        'FrontendTarget'           = $Fronttarget;
                                        'FrontendType'             = $FrontType;
                                        'FrontendSubnet'           = $frontsub;
                                        'BackendPoolName'         = $3.name;
                                        'BackendTarget'            = $BackTarget;
                                        'BackendType'              = $BackType;
                                        'ProbeName'                = $null;
                                        'ProbeIntervalSec'      = $null;
                                        'ProbeProtocol'            = $null;
                                        'ProbePort'                = $null;
                                        'ProbeUnhealthyThreshold' = $null;
                                        'ResourceU'                = $ResUCount;
                                        'TagName'                  = [string]$Tag.Name;
                                        'TagValue'                 = [string]$Tag.Value;
                                        'Time'                 = $ExtractionRunTime
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) { $ResUCount = 0 }          
                                }                           
                        }
                    }
                }   
                elseif ($null -ne $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -eq $data.probes) {
                    foreach ($2 in $data.frontendIPConfigurations) {
                        $Fronttarget = ''    
                        $Frontsub = ''
                        if ($null -ne $2.properties.subnet.id) {
                            $Fronttarget = $2.properties.subnet.id.split('/')[8]
                            $Frontsub = $2.properties.subnet.id.split('/')[10]
                            $FrontType = 'VNET' 
                        }
                        elseif ($null -ne $2.properties.publicIPAddress.id) {
                            $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                            $Frontsub = ''
                            $FrontType = 'Public IP' 
                        }         
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                        = $1.id;
                                    'Subscription'              = $sub1.Name;
                                    'ResourceGroup'            = $1.RESOURCEGROUP;
                                    'Name'                      = $1.NAME;
                                    'Location'                  = $1.LOCATION;
                                    'SKU'                       = $1.sku.name;
                                    'FrontendName'             = $2.name;
                                    'FrontendTarget'           = $Fronttarget;
                                    'FrontendType'             = $FrontType;
                                    'FrontendSubnet'           = $frontsub;
                                    'BackendPoolName'         = $null;
                                    'BackendTarget'            = $null;
                                    'BackendType'              = $null;
                                    'ProbeName'                = $null;
                                    'ProbeIntervalSec'      = $null;
                                    'ProbeProtocol'            = $null;
                                    'ProbePort'                = $null;
                                    'ProbeUnhealthyThreshold' = $null;
                                    'ResourceU'                = $ResUCount;
                                    'TagName'                  = [string]$Tag.Name;
                                    'TagValue'                 = [string]$Tag.Value;
                                    'Time'                 = $ExtractionRunTime
                                }
                                $tmp += $obj   
                                if ($ResUCount -eq 1) { $ResUCount = 0 }      
                            }                       
                    }
                }   
                elseif ($null -ne $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -ne $data.probes) {
                    foreach ($2 in $data.frontendIPConfigurations) {
                        $Fronttarget = ''    
                        $Frontsub = ''
                        if ($null -ne $2.properties.subnet.id) {
                            $Fronttarget = $2.properties.subnet.id.split('/')[8]
                            $Frontsub = $2.properties.subnet.id.split('/')[10]
                            $FrontType = 'VNET' 
                        }
                        elseif ($null -ne $2.properties.publicIPAddress.id) {
                            $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                            $Frontsub = ''
                            $FrontType = 'Public IP' 
                        }        
                        foreach ($3 in $data.probes) {
                                foreach ($Tag in $Tags) {
                                    $obj = @{
                                        'ID'                        = $1.id;
                                        'Subscription'              = $sub1.Name;
                                        'ResourceGroup'            = $1.RESOURCEGROUP;
                                        'Name'                      = $1.NAME;
                                        'Location'                  = $1.LOCATION;
                                        'SKU'                       = $1.sku.name;
                                        'FrontendName'             = $2.name;
                                        'FrontendTarget'           = $Fronttarget;
                                        'FrontendType'             = $FrontType;
                                        'FrontendSubnet'           = $frontsub;
                                        'BackendPoolName'         = $null;
                                        'BackendTarget'            = $null;
                                        'BackendType'              = $null;
                                        'ProbeName'                = $3.name;
                                        'ProbeIntervalSec'      = $3.properties.intervalInSeconds;
                                        'ProbeProtocol'            = $3.properties.protocol;
                                        'ProbePort'                = $3.properties.port;
                                        'ProbeUnhealthyThreshold' = $3.properties.numberOfProbes;
                                        'ResourceU'                = $ResUCount;
                                        'TagName'                  = [string]$Tag.Name;
                                        'TagValue'                 = [string]$Tag.Value;
                                        'Time'                 = $ExtractionRunTime
                                    }
                                    $tmp += $obj  
                                    if ($ResUCount -eq 1) { $ResUCount = 0 }     
                                }                           
                        }
                    }
                }   
                elseif ($null -eq $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -ne $data.probes) {
                    foreach ($2 in $data.backendAddressPools) {
                        $BackTarget = ''
                        $BackType = ''
                        if ($null -ne $3.properties.backendIPConfigurations.id) {
                            $BackTarget = $2.properties.backendIPConfigurations.id.split('/')[8]
                            $BackType = $2.properties.backendIPConfigurations.id.split('/')[7]
                        }
                        foreach ($3 in $data.probes) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'ID'                        = $1.id;
                                        'Subscription'              = $sub1.Name;
                                        'ResourceGroup'            = $1.RESOURCEGROUP;
                                        'Name'                      = $1.NAME;
                                        'Location'                  = $1.LOCATION;
                                        'SKU'                       = $1.sku.name;
                                        'FrontendName'             = $null;
                                        'FrontendTarget'           = $null;
                                        'FrontendType'             = $null;
                                        'FrontendSubnet'           = $null;
                                        'BackendPoolName'         = $2.name;
                                        'BackendTarget'            = $BackTarget;
                                        'BackendType'              = $BackType;
                                        'ProbeName'                = $3.name;
                                        'ProbeIntervalSec'      = $3.properties.intervalInSeconds;
                                        'ProbeProtocol'            = $3.properties.protocol;
                                        'ProbePort'                = $3.properties.port;
                                        'ProbeUnhealthythreshold' = $3.properties.numberOfProbes;
                                        'ResourceU'                = $ResUCount;
                                        'TagName'                  = [string]$TagKey;
                                        'TagValue'                 = [string]$Tag.$TagKey;
                                        'Time'                 = $ExtractionRunTime
                                    }
                                    $tmp += $obj   
                                    if ($ResUCount -eq 1) { $ResUCount = 0 }     
                                }
                            }
                            else { 
                                $obj = @{
                                    'ID'                        = $1.id;
                                    'Subscription'              = $sub1.Name;
                                    'ResourceGroup'            = $1.RESOURCEGROUP;
                                    'Name'                      = $1.NAME;
                                    'Location'                  = $1.LOCATION;
                                    'SKU'                       = $1.sku.name;
                                    'FrontendName'             = $null;
                                    'FrontendTarget'           = $null;
                                    'FrontendType'             = $null;
                                    'FrontendSubnet'           = $null;
                                    'BackendPoolName'         = $2.name;
                                    'BackendTarget'            = $BackTarget;
                                    'BackendType'              = $BackType;
                                    'ProbeName'                = $3.name;
                                    'ProbeIntervalSec'      = $3.properties.intervalInSeconds;
                                    'ProbeProtocol'            = $3.properties.protocol;
                                    'ProbePort'                = $3.properties.port;
                                    'ProbeUnhealthythreshold' = $3.properties.numberOfProbes;
                                    'ResourceU'                = $ResUCount;
                                    'TagName'                  = $null;
                                    'TagValue'                 = $null;
                                    'Time'                 = $ExtractionRunTime
                                }
                                $tmp += $obj   
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }     
                        }
                    }            
                }    
                elseif ($null -eq $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -ne $data.probes) {
                    foreach ($2 in $data.probes) {
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                       = $1.id;
                                    'Subscription'             = $sub1.Name;
                                    'ResourceGroup'            = $1.RESOURCEGROUP;
                                    'Name'                     = $1.NAME;
                                    'Location'                 = $1.LOCATION;
                                    'SKU'                      = $1.sku.name;
                                    'FrontendName'             = $null;
                                    'FrontendTarget'           = $null;
                                    'FrontendType'             = $null;
                                    'FrontendSubnet'           = $null;
                                    'BackendPoolName'          = $null;
                                    'BackendTarget'            = $null;
                                    'BackendType'              = $null;
                                    'ProbeName'                = $2.name;
                                    'ProbeIntervalSec'         = $2.properties.intervalInSeconds;
                                    'ProbeProtocol'            = $2.properties.protocol;
                                    'ProbePort'                = $2.properties.port;
                                    'ProbeUnhealthythreshold'  = $2.properties.numberOfProbes;
                                    'ResourceU'                = $ResUCount;
                                    'TagName'                  = [string]$Tag.Name;
                                    'TagValue'                 = [string]$Tag.Value;
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
    if ($SmaResources.LoadBalancer) {

        $TableName = ('LBTable_'+($SmaResources.LoadBalancer.id | Select-Object -Unique).count)
        $txtLB = New-ConditionalText Basic -Range E:E
                        
        #$Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Frontend Name')
        $Exc.Add('Frontend Target')
        $Exc.Add('Frontend Type')
        $Exc.Add('Frontend Subnet')
        $Exc.Add('Backend Pool Name')
        $Exc.Add('Backend Target')
        $Exc.Add('Backend Type')
        $Exc.Add('Probe Name')
        $Exc.Add('Probe Interval (sec)')
        $Exc.Add('Probe Protocol')
        $Exc.Add('Probe Port')
        $Exc.Add('Probe Unhealthy threshold')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.LoadBalancer 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Load Balancers' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $txtLB -Style $Style
    
        # <######## Insert Column comments and documentations here following this model #########>

        # $excel = Open-ExcelPackage -Path $File -KillExcel

        # $null = $excel.'Load Balancers'.Cells["E1"].AddComment("No SLA is provided for Basic Load Balancer!", "Azure Resource Inventory")
        # $excel.'Load Balancers'.Cells["E1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/load-balancer/skus'

        # Close-ExcelPackage $excel 

    }
    
}