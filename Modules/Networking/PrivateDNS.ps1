﻿<#
.Synopsis
Inventory for Azure Private DNS

.DESCRIPTION
This script consolidates information for all microsoft.network/privatednszones and  resource provider in $Resources variable. 
Excel Sheet Name: PrivateDNS

.Link
https://github.com/microsoft/ARI/Modules/Networking/PrivateDNS.ps1

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

    $PrivateDNS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privatednszones' }
    $VNETLinks =  $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privatednszones/virtualnetworklinks' }

    if($PrivateDNS)
        {
            $tmp = @()

            foreach ($1 in $PrivateDNS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES

                $vnlks = ($VNETLinks | where {$_.id -like ($1.id + '*')})
                $vnlks = if (!$vnlks) {[pscustomobject]@{id = 'none'}} else {$vnlks | Select-Object @{Name="id";Expression={$_.properties.virtualNetwork.id.split("/")[8]}}}

                foreach ($2 in $vnlks) {

                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    
                    foreach ($Tag in $Tags) {     
                        $obj = @{
                            'ID'                              = $1.id;
                            'Subscription'                    = $sub1.Name;
                            'ResourceGroup'                  = $1.RESOURCEGROUP;
                            'Name'                            = $1.NAME;
                            'Location'                        = $1.LOCATION;
                            'NumberofRecords'               = $data.numberOfRecordSets;
                            'VirtualNetworkLinks'           = $data.numberOfVirtualNetworkLinks;
                            'NetworkLinkswithRegistration' = $data.numberOfVirtualNetworkLinksWithRegistration;
                            'TagName'                        = [string]$Tag.Name;
                            'TagValue'                       = [string]$Tag.Value;
                            'VirtualNetwork'                 = $2.id;
                            'Time'                 = $ExtractionRunTime
                        }
             
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }               
            }
            $tmp
            DataSource-Management -TableName $ModName -tmp $tmp 
        }
}
Else {
    if ($SmaResources.PrivateDNS) {

        $TableName = ('PrivDNSTable_'+($SmaResources.PrivateDNS.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Number of Records')
        $Exc.Add('Virtual Network Links')
        $Exc.Add('Virtual Network')
        $Exc.Add('Network Links with Registration')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.PrivateDNS

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Private DNS' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style
    
    }   
}