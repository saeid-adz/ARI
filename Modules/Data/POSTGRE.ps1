<#
.Synopsis
Inventory for Azure Database for Postgre

.DESCRIPTION
This script consolidates information for all microsoft.dbforpostgresql/servers resource provider in $Resources variable. 
Excel Sheet Name: POSTGRE

.Link
https://github.com/microsoft/ARI/Modules/Data/POSTGRE.ps1

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

    $POSTGRE = $Resources | Where-Object { $_.TYPE -eq 'microsoft.dbforpostgresql/servers' }

    if($POSTGRE)
        {
            $tmp = @()

            foreach ($1 in $POSTGRE) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                if([string]::IsNullOrEmpty($data.privateEndpointConnections)){$PVTENDP = $false}else{$PVTENDP = $data.privateEndpointConnections.Id.split("/")[8]}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'ResourceGroup'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'SKU'                       = $sku.name;
                            'SKUFamily'                = $sku.family;
                            'Tier'                      = $sku.tier;
                            'Capacity'                  = $sku.capacity;
                            'PostgreVersion'           = $data.version;
                            'PrivateEndpoint'          = $PVTENDP;
                            'BackupRetentionDays'     = $data.storageProfile.backupRetentionDays;
                            'GeoRedundantBackup'      = $data.storageProfile.geoRedundantBackup;
                            'AutoGrow'                 = $data.storageProfile.storageAutogrow;
                            'StorageMB'                = $data.storageProfile.storageMB;
                            'PublicNetworkAccess'     = $data.publicNetworkAccess;
                            'AdminLogin'               = $data.administratorLogin;
                            'InfrastructureEncryption' = $data.InfrastructureEncryption;
                            'MinimumTLSVersion'       = "$($data.minimalTlsVersion -Replace '_', '.' -Replace 'tls', 'TLS')";
                            'State'                     = $data.userVisibleState;
                            'ReplicaCapacity'          = $data.replicaCapacity;
                            'ReplicationRole'          = $data.replicationRole;
                            'BYOKEnforcement'          = $data.byokEnforcement;
                            'SSLEnforcement'           = $data.sslEnforcement;
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
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.POSTGRE) {

        $TableName = ('POSTGRETable_'+($SmaResources.POSTGRE.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range J:J
        $condtxt += New-ConditionalText FALSO -Range J:J
        $condtxt += New-ConditionalText Disabled -Range L:L
        $condtxt += New-ConditionalText Enabled -Range O:O
        $condtxt += New-ConditionalText TLSEnforcementDisabled -Range R:R
        $condtxt += New-ConditionalText Disabled -Range W:W


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('SKU Family')
        $Exc.Add('Tier')
        $Exc.Add('Capacity')
        $Exc.Add('Postgre Version')
        $Exc.Add('Private Endpoint')
        $Exc.Add('Backup Retention Days')
        $Exc.Add('Geo-Redundant Backup')
        $Exc.Add('Auto Grow')
        $Exc.Add('Storage MB')
        $Exc.Add('Public Network Access')
        $Exc.Add('Admin Login')
        $Exc.Add('Infrastructure Encryption')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('State')
        $Exc.Add('Replica Capacity')
        $Exc.Add('Replication Role')
        $Exc.Add('BYOK Enforcement')
        $Exc.Add('SSL Enforcement')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.POSTGRE 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'PostgreSQL' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
