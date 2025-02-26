﻿<#
.Synopsis
Inventory for Azure Public DNS

.DESCRIPTION
This script consolidates information for all microsoft.network/dnszones and  resource provider in $Resources variable. 
Excel Sheet Name: PublicDNS

.Link
https://github.com/microsoft/ARI/Modules/Networking/PublicDNS.ps1

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

    $PublicDNS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/dnszones' }

    if($PublicDNS)
        {
            $tmp = @()

            foreach ($1 in $PublicDNS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {     
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'ResourceGroup'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'ZoneType'                 = $data.zoneType;
                            'NumberofRecordSets'     = $data.numberOfRecordSets;
                            'MaxNumberofRecordSets' = $data.maxNumberofRecordSets;
                            'NameServers'              = [string]$data.nameServers;
                            'ResourceU'                = $ResUCount;
                            'TagName'                  = [string]$Tag.Name;
                            'TagValue'                 = [string]$Tag.Value;
                            'Time'                 = $ExtractionRunTime
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
            DataSource-Management -TableName $ModName -tmp $tmp 
        }
}
Else {
    if ($SmaResources.PublicDNS) {

        $TableName = ('PubDNSTable_'+($SmaResources.PublicDNS.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone Type')
        $Exc.Add('Number of Record Sets')
        $Exc.Add('Max Number of Record Sets')
        $Exc.Add('Name Servers')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.PublicDNS 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Public DNS' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}