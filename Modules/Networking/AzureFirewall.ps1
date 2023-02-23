<#
.Synopsis
Inventory for Azure Firewall

.DESCRIPTION
This script consolidates information for all microsoft.network/azurefirewalls and  resource provider in $Resources variable. 
Excel Sheet Name: AzureFirewall

.Link
https://github.com/microsoft/ARI/Modules/Networking/AzureFirewall.ps1

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

    <######### Insert the resource extraction here ########>
    $AzureFirewall = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/azurefirewalls' }

    if($AzureFirewall)
        {
            $tmp = @()

            foreach ($1 in $AzureFirewall) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if ($1.zones) { $Zones = $1.zones } Else { $Zones = "Not Configured" }
                $Threat = if($data.threatintelmode -eq 'deny'){'Alert and deny'}elseif($data.threatintelmode -eq 'alert'){'Alert only'}else{'Off'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                Foreach($2 in $data.ipConfigurations)
                    {
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'ResourceGroup'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'SKU'                               = $data.sku.tier;
                            'ThreatIntelMode'                 = $Threat;
                            'Zone'                              = $Zones;
                            'NATRules'                         = [int]$data.natRuleCollections.Count;
                            'ApplicationRules'                 = [int]$data.applicationRuleCollections.Count;
                            'NetworkRules'                     = [int]$data.networkRuleCollections.Count;
                            'PublicIPName'                    = $2.name;
                            'FirewallVNET'                     = $2.properties.subnet.id.split('/')[8];
                            'FirewallPrivateIP'               = $2.properties.privateIPAddress;
                            'ResourceU'                        = $ResUCount;
                            'TagName'                          = [string]$Tag.Name;
                            'TagValue'                         = [string]$Tag.Value;
                            'Time'                 = $ExtractionRunTime
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }               
            }
            $tmp
            DataSource-Management -TableName $ModName -tmp $tmp 
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.AzureFirewall) {

        $TableName = ('AzFirewallTable_'+($SmaResources.AzureFirewall.id | Select-Object -Unique).count)
        $condtxt = @()
        $condtxt += New-ConditionalText Off -Range F:F

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Threat Intel Mode')
        $Exc.Add('Zone')
        $Exc.Add('NAT Rules')
        $Exc.Add('Application Rules')
        $Exc.Add('Network Rules')
        $Exc.Add('Public IP Name')
        $Exc.Add('Firewall VNET')
        $Exc.Add('Firewall Private IP')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AzureFirewall 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Azure Firewall' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}