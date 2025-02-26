<#
.Synopsis
Inventory for Azure Databricks

.DESCRIPTION
This script consolidates information for all microsoft.databricks/workspaces resource provider in $Resources variable. 
Excel Sheet Name: Databricks

.Link
https://github.com/microsoft/ARI/Modules/Data/Databricks.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.10
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    $DataBricks = $Resources | Where-Object { $_.TYPE -eq 'microsoft.databricks/workspaces' }

    if($DataBricks)
        {
            $tmp = @()

            foreach ($1 in $DataBricks) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $PIP = if($data.parameters.enableNoPublicIp.value -eq 'False'){$true}else{$false}
                $VNET = $data.parameters.customVirtualNetworkId.value.split('/')[8]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Pricing Tier'              = $sku.name;
                            'ManagedResourceGroup'    = $data.managedResourceGroupId.split('/')[4];
                            'StorageAccount'           = $data.parameters.storageAccountName.value;
                            'StorageAccountSKU'       = $data.parameters.storageAccountSkuName.value;
                            'InfrastructureEncryption' = $data.parameters.requireInfrastructureEncryption.value;
                            'PrepareEncryption'        = $data.parameters.prepareEncryption.value;
                            'EnablePublicIP'          = $PIP;
                            'CustomVirtualNetwork'    = $VNET;
                            'CustomPrivateSubnet'     = $data.parameters.customPrivateSubnetName.value;
                            'CustomPublicSubnet'      = $data.parameters.customPublicSubnetName.value;
                            'URL'                       = $data.workspaceUrl;
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

    if ($SmaResources.Databricks) {

        $TableName = ('DBricksTable_'+($SmaResources.Databricks.id | Select-Object -Unique).count)
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
        $Exc.Add('Pricing Tier')
        $Exc.Add('Managed Resource Group')
        $Exc.Add('Storage Account')
        $Exc.Add('Storage Account SKU')
        $Exc.Add('Infrastructure Encryption')
        $Exc.Add('Prepare Encryption')
        $Exc.Add('Enable Public IP')
        $Exc.Add('Custom Virtual Network')
        $Exc.Add('Custom Private Subnet')
        $Exc.Add('Custom Public Subnet')
        $Exc.Add('URL')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.Databricks

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Databricks' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}