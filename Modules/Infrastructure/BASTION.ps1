﻿<#
.Synopsis
Inventory for Azure Bastion Hosts

.DESCRIPTION
This script consolidates information for all microsoft.network/bastionhosts and  resource provider in $Resources variable. 
Excel Sheet Name: BASTION

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/BASTION.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $BASTION = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/bastionhosts'}

    <######### Insert the resource Process here ########>

    if($BASTION)
        {
            $tmp = @()

            foreach ($1 in $BASTION) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $BastVNET = $data.ipConfigurations.properties.subnet.id.split("/")[8]
                $BastPIP = $data.ipConfigurations.properties.publicIPAddress.id.split("/")[8]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'              = $1.id;
                            'Subscription'    = $sub1.Name;
                            'ResourceGroup'  = $1.RESOURCEGROUP;
                            'Name'            = $1.NAME;
                            'Location'        = $1.LOCATION;
                            'SKU'             = $1.sku.name;
                            'DNSName'        = $data.dnsName;
                            'VirtualNetwork' = $BastVNET;
                            'PublicIP'       = $BastPIP;
                            'ScaleUnits'     = $data.scaleUnits;
                            'TagName'        = [string]$Tag.Name;
                            'TagValue'       = [string]$Tag.Value;
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

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.BASTION)
    {

        $TableName = ('BASTIONTable_'+($SmaResources.BASTION.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('DNS Name')
        $Exc.Add('Virtual Network')
        $Exc.Add('Public IP')
        $Exc.Add('Scale Units')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.BASTION  

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Bastion Hosts' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}