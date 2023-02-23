﻿<#
.Synopsis
Inventory for Azure Express Route Circuits

.DESCRIPTION
This script consolidates information for all microsoft.network/expressroutecircuits and  resource provider in $Resources variable. 
Excel Sheet Name: EvHub

.Link
https://github.com/microsoft/ARI/Modules/Networking/ExpressRoute.ps1

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

        $expressroute = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/expressroutecircuits'}

    <######### Insert the resource Process here ########>

    if($expressroute)
        {
            $tmp = @()

            foreach ($1 in $expressroute) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.name;
                            'ResourceGroup'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'tier'                 = $sku.tier;
                            'BillingModel'        = $sku.family;
                            'Circuitstatus'       = $data.circuitProvisioningState;
                            'ProviderStatus'      = $data.serviceProviderProvisioningState;
                            'Provider'             = $data.serviceProviderProperties.serviceProviderName;
                            'Bandwidth'            = $data.bandwidthInMbps;
                            'ERLocation'          = $data.peeringLocation;
                            'GlobalReachEnabled'  = $data.globalReachEnabled;
                            'ResourceU'           = $ResUCount;
                            'TagName'             = [string]$Tag.Name;
                            'TagValue'            = [string]$Tag.Value;
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

    if($SmaResources.expressroute)
    {
        $TableName = ('ERs_'+($SmaResources.expressroute.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('tier')
        $Exc.Add('Billing Model')
        $Exc.Add('Circuit status')
        $Exc.Add('Provider Status')
        $Exc.Add('Provider')
        $Exc.Add('Bandwidth')
        $Exc.Add('ER Location')
        $Exc.Add('GlobalReach Enabled')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.expressroute  

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Express Route' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>

        #Close-ExcelPackage $excel 
    }
}