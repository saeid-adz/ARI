<#
.Synopsis
Inventory for Azure Container Registries instance

.DESCRIPTION
This script consolidates information for all microsoft.containerinstance/containergroups resource provider in $Resources variable. 
Excel Sheet Name: REGISTRIES

.Link
https://github.com/microsoft/ARI/Modules/Compute/CONTAINERREGISTRIES.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.3.0
First Release Date: 19th November, 2022
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $REGISTRIES = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerregistry/registries'}

    <######### Insert the resource Process here ########>

    if($REGISTRIES)
        {
            $tmp = @()

            foreach ($1 in $REGISTRIES) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($Tag in $Tags) {
                    $obj = @{
                        'ID'                        = $1.id;
                        'Subscription'              = $sub1.Name;
                        'ResourceGroup'            = $1.RESOURCEGROUP;
                        'Name'                      = $1.NAME;
                        'Location'                  = $1.LOCATION;
                        'SKU'                       = $1.sku.name;
                        'AnonymousPullEnabled'    = $data.anonymouspullenabled;
                        'Encryption'                = $data.encryption.status;
                        'PublicNetworkAccess'     = $data.publicnetworkaccess;
                        'ZoneRedundancy'           = $data.zoneredundancy;
                        'PrivateLink'              = if($data.privateendpointconnections){'True'}else{'False'};
                        'SoftDeletePolicy'        = $data.policies.softdeletepolicy.status;
                        'TrustPolicy'              = $data.policies.trustpolicy.status;
                        'ResourceU'                = $ResUCount;
                        'Total'                     = $Total;
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.REGISTRIES)
    {
        $TableName = ('ContsTable_'+($SmaResources.REGISTRIES.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $cond = @()

        #Anonymous Pull Enabled
        $cond += New-ConditionalText True -Range F:F

        #Encryption
        $cond += New-ConditionalText disabled -Range G:G

        #Public Network Access
        $cond += New-ConditionalText enabled -Range H:H

        #Zone Redundancy
        $cond += New-ConditionalText disabled -Range I:I

        #Private Link
        $cond += New-ConditionalText False -Range J:J

        #Soft Delete Policy
        $cond += New-ConditionalText disabled -Range K:K

        #Trust Policy
        $cond += New-ConditionalText disabled -Range L:L

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Anonymous Pull Enabled')
        $Exc.Add('Encryption')
        $Exc.Add('Public Network Access')
        $Exc.Add('Zone Redundancy')
        $Exc.Add('Private Link')
        $Exc.Add('Soft Delete Policy')
        $Exc.Add('Trust Policy')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.REGISTRIES 
            
        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Registries' -AutoSize -ConditionalText $cond -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}