﻿<#
.Synopsis
Inventory for Azure Function and App Services

.DESCRIPTION
This script consolidates information for all microsoft.web/sites resource provider in $Resources variable. 
Excel Sheet Name: APPServices

.Link
https://github.com/microsoft/ARI/Modules/Compute/APPServices.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $AppSvc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.web/sites'}

    <######### Insert the resource Process here ########>

    if($AppSvc)
        {
            $tmp = @()

            foreach ($1 in $AppSvc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if([string]::IsNullOrEmpty($data.siteConfig.ftpsState)){$FTPS = $false}else{$FTPS = $data.siteConfig.ftpsState}
                if([string]::IsNullOrEmpty($data.SiteConfig.acrUseManagedIdentityCreds)){$MGMID = $false}else{$MGMID = $true}
                if([string]::IsNullOrEmpty($data.virtualNetworkSubnetId)){$VNET = $false}else{$VNET = $data.virtualNetworkSubnetId.split("/")[8]}
                if([string]::IsNullOrEmpty($data.virtualNetworkSubnetId)){
                    $VNET = $false
                    $SUBNET = $false
                }else{
                    
                    $VNET = $data.virtualNetworkSubnetId.split("/")[8]
                    $SUBNET = $data.virtualNetworkSubnetId.split("/")[10]
                }
                
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.hostNameSslStates) {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                            = $1.id;
                                'Subscription'                  = $sub1.Name;
                                'ResourceGroup'                = $1.RESOURCEGROUP;
                                'Name'                          = $1.NAME;
                                'AppType'                      = $1.KIND;
                                'Location'                      = $1.LOCATION;
                                'Enabled'                       = $data.enabled;
                                'State'                         = $data.state;
                                'SKU'                           = $data.sku;
                                'ClientCertEnabled'           = $data.clientCertEnabled;
                                'ClientCertMode'              = $data.clientCertMode;
                                'ContentAvailabilityState'    = $data.contentAvailabilityState;
                                'RuntimeAvailabilityState'    = $data.runtimeAvailabilityState;
                                'HTTPSOnly'                    = $data.httpsOnly;
                                'FTPSOnly'                     = $FTPS;
                                'PossibleInboundIPAddresses' = $data.possibleInboundIpAddresses;
                                'RepositorySiteName'          = $data.repositorySiteName;
                                'ManagedIdentity'              = $MGMID;
                                'AvailabilityState'            = $data.availabilityState;
                                'HostNames'                     = $2.Name;
                                'HostNameType'                 = $2.hostType;
                                'Stack'                         = $data.SiteConfig.linuxFxVersion;
                                'VirtualNetwork'               = [string]$VNET;
                                'Subnet'                        = [string]$SUBNET;
                                'SSLState'                     = $2.sslState;
                                'DefaultHostname'              = $data.defaultHostName;                        
                                'ContainerSize'                = $data.containerSize;
                                'AdminEnabled'                 = $data.adminEnabled;                        
                                'FTPsHostName'                = $data.ftpsHostName;                        
                                'ResourceU'                    = $ResUCount;
                                'TagName'                      = [string]$Tag.Name;
                                'TagValue'                     = [string]$Tag.Value
                                'Time'                          = $ExtractionRunTime
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.APPSERVICES)
    {

        $TableName = ('AppSvcsTable_'+($SmaResources.APPSERVICES.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        Foreach ($UnSupOS in $Unsupported.WebSite)
            {                
                $condtxt += New-ConditionalText $UnSupOS -Range U:U
            }
        
        $condtxt += New-ConditionalText FALSE -Range M:M
        $condtxt += New-ConditionalText FALSO -Range M:M
        $condtxt += New-ConditionalText FALSE -Range N:N
        $condtxt += New-ConditionalText FALSO -Range N:N
        $condtxt += New-ConditionalText FALSE -Range I:I
        $condtxt += New-ConditionalText FALSO -Range I:I
        $condtxt += New-ConditionalText FALSE -Range Q:Q
        $condtxt += New-ConditionalText FALSO -Range Q:Q

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('App Type')
        $Exc.Add('Location')
        $Exc.Add('Enabled')
        $Exc.Add('State')
        $Exc.Add('SKU')
        $Exc.Add('Client Cert Enabled')
        $Exc.Add('Client Cert Mode')
        $Exc.Add('Content Availability State')
        $Exc.Add('Runtime Availability State')
        $Exc.Add('HTTPS Only')
        $Exc.Add('FTPS Only')
        $Exc.Add('Possible Inbound IP Addresses')
        $Exc.Add('Repository Site Name')
        $Exc.Add('Managed Identity')
        $Exc.Add('Availability State')
        $Exc.Add('HostNames')
        $Exc.Add('HostName Type')
        $Exc.Add('Stack')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('SSL State')
        $Exc.Add('Default Hostname')                      
        $Exc.Add('Container Size')
        $Exc.Add('Admin Enabled')                       
        $Exc.Add('FTPs Host Name')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.APPSERVICES 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'App Services' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}