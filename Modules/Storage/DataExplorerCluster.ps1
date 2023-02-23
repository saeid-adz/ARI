<#
.Synopsis
Inventory for Azure Data Explorer

.DESCRIPTION
This script consolidates information for all microsoft.kusto/clusters resource provider in $Resources variable. 
Excel Sheet Name: DataExplorerCluster

.Link
https://github.com/microsoft/ARI/Modules/Data/DataExplorerCluster.ps1

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

    $DataExplorer = $Resources | Where-Object { $_.TYPE -eq 'microsoft.kusto/clusters' }

    if($DataExplorer)
        {
            $tmp = @()

            foreach ($1 in $DataExplorer) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $VNET = $data.virtualNetworkConfiguration.subnetid.split('/')[8]
                $Subnet = $data.virtualNetworkConfiguration.subnetid.split('/')[10]
                $DataPIP = $data.virtualNetworkConfiguration.dataManagementPublicIpId.split('/')[8]
                $EnginePIP = $data.virtualNetworkConfiguration.enginePublicIpId.split('/')[8]
                $TenantPerm = if($data.trustedExternalTenants.value -eq '*'){'All Tenants'}else{$data.trustedExternalTenants.value}
                $AutoScale = if($data.optimizedAutoscale.isEnabled -eq 'true'){'Enabled'}else{'Disabled'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'ResourceGroup'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'ComputeSpecifications'    = $sku.name;
                            'Instancecount'            = $sku.capacity;
                            'State'                     = $data.state;
                            'StateReason'              = $data.stateReason;
                            'VirtualNetwork'           = $VNET;
                            'Subnet'                    = $Subnet;
                            'DataManagementPublicIP' = $DataPIP;
                            'EnginePublicIP'          = $EnginePIP;
                            'TenantsPermissions'       = $TenantPerm;
                            'DiskEncryption'           = $data.enableDiskEncryption;
                            'StreamingIngestion'       = $data.enableStreamingIngest;
                            'OptimizedAutoscale'       = $AutoScale;
                            'OptimizedAutoscaleMin'   = $data.optimizedAutoscale.minimum;
                            'OptimizedAutoscaleMax'   = $data.optimizedAutoscale.maximum;
                            'URI'                       = $data.uri;
                            'DataIngestionUri'        = $data.dataIngestionUri;
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

    if ($SmaResources.DataExplorerCluster) {

        $TableName = ('DTExplTable_'+($SmaResources.DataExplorerCluster.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText 'All Tenants' -Range M:M
        $condtxt += New-ConditionalText FALSO -Range N:N
        $condtxt += New-ConditionalText FALSE -Range N:N
        $condtxt += New-ConditionalText Disabled -Range P:P


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Compute specifications')
        $Exc.Add('Instance count')
        $Exc.Add('State')
        $Exc.Add('State Reason')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('Data Management Public IP')
        $Exc.Add('Engine Public IP')
        $Exc.Add('Tenants Permissions')
        $Exc.Add('Disk Encryption')
        $Exc.Add('Streaming Ingestion')
        $Exc.Add('Optimized Autoscale')
        $Exc.Add('Optimized Autoscale Min')
        $Exc.Add('Optimized Autoscale Max')
        $Exc.Add('URI')
        $Exc.Add('Data Ingestion Uri')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.DataExplorerCluster 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Data Explorer Clusters' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}