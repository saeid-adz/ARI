<#
.Synopsis
Inventory for Azure SQL Virtual Machine

.DESCRIPTION
This script consolidates information for all microsoft.sqlvirtualmachine/sqlvirtualmachines resource provider in $Resources variable. 
Excel Sheet Name: SQLVM

.Link
https://github.com/microsoft/ARI/Modules/Data/SQLVM.ps1

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

    <######### Insert the resource extraction here ########>

    $SQLVM = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sqlvirtualmachine/sqlvirtualmachines' }

    if($SQLVM)
        {
            $tmp = @()

            foreach ($1 in $SQLVM) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                      = $1.id;
                            'Subscription'            = $sub1.Name;
                            'ResourceGroup'          = $1.RESOURCEGROUP;
                            'Name'                    = $1.NAME;
                            'Location'                = $1.LOCATION;
                            'Zone'                    = $1.ZONES;
                            'SQLServerLicenseType' = $data.sqlServerLicenseType;
                            'SQLImage'               = $data.sqlImageOffer;
                            'SQLManagement'          = $data.sqlManagement;
                            'SQLImageSku'           = $data.sqlImageSku;
                            'ResourceU'              = $ResUCount;
                            'TagName'                = [string]$Tag.Name;
                            'TagValue'               = [string]$Tag.Value;
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

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.SQLVM) {

        $TableName = ('SQLVMTable_'+($SmaResources.SQLVM.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('SQL Server License Type')
        $Exc.Add('SQL Image')
        $Exc.Add('SQL Management')
        $Exc.Add('SQL Image Sku')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.SQLVM 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'SQL VMs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}