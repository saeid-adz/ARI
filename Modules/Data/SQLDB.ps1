﻿<#
.Synopsis
Inventory for Azure SQLDB

.DESCRIPTION
This script consolidates information for all microsoft.sql/servers/databases resource provider in $Resources variable. 
Excel Sheet Name: SQLDB

.Link
https://github.com/microsoft/ARI/Modules/Data/SQLDB.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 

if ($Task -eq 'Processing') {

    $SQLDB = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sql/servers/databases' -and $_.name -ne 'master' }

    if($SQLDB)
        {
            $tmp = @()

            foreach ($1 in $SQLDB) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $DBServer = [string]$1.id.split("/")[8]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                         = $1.id;
                            'Subscription'               = $sub1.Name;
                            'ResourceGroup'             = $1.RESOURCEGROUP;
                            'Name'                       = $1.NAME;
                            'Location'                   = $1.LOCATION;
                            'StorageAccountType'       = $data.storageAccountType;
                            'DatabaseServer'            = $DBServer;
                            'DefaultSecondaryLocation' = $data.defaultSecondaryLocation;
                            'Status'                     = $data.status;
                            'DTUCapacity'               = $data.currentSku.capacity;
                            'DTUTier'                   = $data.requestedServiceObjectiveName;
                            'ZoneRedundant'             = $data.zoneRedundant;
                            'CatalogCollation'          = $data.catalogCollation;
                            'ReadReplicaCount'         = $data.readReplicaCount;
                            'DataMaxSizeGB'         = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                            'ResourceU'                 = $ResUCount;
                            'TagName'                   = [string]$Tag.Name;
                            'TagValue'                  = [string]$Tag.Value;
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
else {
    if ($SmaResources.SQLDB) {

        $TableName = ('SQLDBTable_'+($SmaResources.SQLDB.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Storage Account Type')
        $Exc.Add('Database Server')
        $Exc.Add('Default Secondary Location')
        $Exc.Add('Status')
        $Exc.Add('DTU Capacity')
        $Exc.Add('DTU Tier')
        $Exc.Add('Data Max Size (GB)')
        $Exc.Add('Zone Redundant')
        $Exc.Add('Catalog Collation')
        $Exc.Add('Read Replica Count')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.SQLDB 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'SQL DBs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}