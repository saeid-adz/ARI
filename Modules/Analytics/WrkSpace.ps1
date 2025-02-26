﻿<#
.Synopsis
Inventory for Azure Log Analytics Workspace

.DESCRIPTION
This script consolidates information for all microsoft.operationalinsights/workspaces and  resource provider in $Resources variable. 
Excel Sheet Name: WrkSpace

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/WrkSpace.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported, $AzCost)
 
If ($Task -eq 'Processing')
{
 
    <######### Insert the resource extraction here ########>

        $wrkspace = $Resources | Where-Object {$_.TYPE -eq 'microsoft.operationalinsights/workspaces'}

    <######### Insert the resource Process here ########>

    if($wrkspace)
        {
            $tmp = @()

            foreach ($1 in $wrkspace) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'               = $1.id;
                            'Subscription'     = $sub1.Name;
                            'ResourceGroup'   = $1.RESOURCEGROUP;
                            'Name'             = $1.NAME;
                            'Location'         = $1.LOCATION;
                            'Currency'         = $Cost.Currency;
                            'DailyCost'       = '{0:C}' -f $Cost.Cost;
                            'SKU'              = $data.sku.name;
                            'RetentionDays'   = $data.retentionInDays;
                            'DailyQuotaGB' = [decimal]$data.workspaceCapping.dailyQuotaGb;
                            'ResourceU'       = $ResUCount;
                            'TagName'         = [string]$Tag.Name;
                            'TagValue'        = [string]$Tag.Value;
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

    if($SmaResources.WrkSpace)
    {

        $TableName = ('WorkSpaceTable_'+($SmaResources.WrkSpace.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0.0'

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retention Days')
        $Exc.Add('Daily Quota (GB)')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.WrkSpace 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Workspaces' -AutoSize -MaxAutoSizeRows 100 -ConditionalText $condtxt -TableName $TableName -TableStyle $tableStyle -Style $Style


        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}