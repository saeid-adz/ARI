﻿<#
.Synopsis
Inventory for Azure Availability Set

.DESCRIPTION
This script consolidates information for all microsoft.compute/availabilitysets and  resource provider in $Resources variable. 
Excel Sheet Name: AvSet

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/AvSet.ps1

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

        $AvSet = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/availabilitysets'}

    <######### Insert the resource Process here ########>

    if($AvSet)
        {
            $tmp = @()

            foreach ($1 in $AvSet) {
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                Foreach ($vmid in $data.virtualMachines.id) {
                    $vmIds = $vmid.split('/')[8]
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'               = $1.id;
                                'Subscription'     = $sub1.Name;
                                'ResourceGroup'   = $1.RESOURCEGROUP;
                                'Name'             = $1.NAME;
                                'Location'         = $1.LOCATION;
                                'FaultDomains'    = [string]$data.platformFaultDomainCount;
                                'UpdateDomains'   = [string]$data.platformUpdateDomainCount;
                                'VirtualMachines' = [string]$vmIds;
                                'TagName'         = [string]$Tag.Name;
                                'TagValue'        = [string]$Tag.Value;
                                'Time'                 = $ExtractionRunTime
                            }
                            $tmp += $obj
                        }                    
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

    if($SmaResources.AvSet)
    {

        $TableName = ('AvSetTable_'+($SmaResources.AvSet.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
            
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Fault Domains')
        $Exc.Add('Update Domains')
        $Exc.Add('Virtual Machines')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AvSet  

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Availability Sets' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}