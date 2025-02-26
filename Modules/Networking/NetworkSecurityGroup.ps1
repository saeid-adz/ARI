<#
.Synopsis
Inventory for Azure Network Security Group

.DESCRIPTION
This script consolidates information for all microsoft.network/Netowrksecuritygroup and resource provider in $Resources variable.
Excel Sheet Name: NetworkSecuritytGroup

.Link
https://github.com/microsoft/ARI/Modules/Networking/NetworkSecurityGroup.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 2021.10.05
Authors: Christopher Lewis

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)
If ($Task -eq 'Processing') {

    $NSGs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/networksecuritygroups' }

    if ($NSGs) {
        $tmp = @()

        foreach ($1 in $NSGs) {
            $ResUCount = 1
            $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
            $data = $1.PROPERTIES
            $Tags = if (![string]::IsNullOrEmpty($1.tags.psobject.properties)) { $1.tags.psobject.properties }else { '0' }
            foreach ($2 in $data.securityRules)
            {
                foreach ($Tag in $Tags) {
                    if ($data.networkInterfaces.count -eq 0 -and $data.subnets.count -eq 0) 
                    {
                        $Orphaned = $true;
                    } else {
                        $Orphaned = $false;
                    }

                    $obj = @{
                        'ID'                           = $1.id;
                        'Subscription'                 = $sub1.Name;
                        'ResourceGroup'               = $1.RESOURCEGROUP;
                        'Name'                         = $1.NAME;
                        'Location'                     = $1.LOCATION;
                        'SecurityRules'               = [string]$2.name;
                        'Direction'                    = [string]$2.properties.direction;
                        'Access'                       = [string]$2.properties.Access;
                        'Priority'                     = [string]$2.properties.priority;
                        'Protocol'                     = [string]$2.properties.protocol;
                        'SourceAddressPrefixes'      = [string]$2.properties.sourceAddressPrefixes;
                        'SourceAddressPrefix'        = [string]$2.properties.sourceAddressPrefix;
                        'SourcePortRanges'           = [string]$2.properties.sourcePortRanges;
                        'SourcePortRange'            = [string]$2.properties.sourcePortRange;
                        'DestinationAddressPrefixes' = [string]$2.properties.destinationAddressPrefixes;
                        'DestinationAddressPrefix'   = [string]$2.properties.destinationAddressPrefix;
                        'DestinationPortRanges'      = [string]$2.properties.destinationPortRanges;
                        'DestinationPortRange'       = [string]$2.properties.destinationPortRange;
                        'NICs'                         = [string]$data.networkInterfaces.id -Join ",";
                        'Subnets'                      = [string]$data.Subnets.id;
                        'Orphaned'                     = $Orphaned;
                        'TagName'                     = [string]$Tag.Name;
                        'TagValue'                    = [string]$Tag.Value;
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
} Else {
    # --------------------------------------------------------------------------------
    # the $SmaResources object for a module should be the same as the name of the file.
    #  In this case the file name is "NetworkSecurityGroup.ps1" so the SMA object
    #  is $SmaResources.NetworkSecurityGroup
    # --------------------------------------------------------------------------------
    $ExcelVar = $SmaResources.NetworkSecurityGroup
    if ($ExcelVar) {

        $TableName = ('NSGTable_'+($SmaResources.NetworkSecurityGroup.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        #Conditional formats.  Note that this can be $() for none
        $condtxt = $(
            New-ConditionalText true -Range T:T
        )

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Security Rules')
        $Exc.Add('Direction')
        $Exc.Add('Access')
        $Exc.Add('Priority')
        $Exc.Add('Protocol')
        $Exc.Add('Source Address Prefixes')
        $Exc.Add('Source Address Prefix')
        $Exc.Add('Source Port Ranges')
        $Exc.Add('Source Port Range')
        $Exc.Add('Destination Address Prefixes')
        $Exc.Add('Destination Address Prefix')
        $Exc.Add('Destination Port Ranges')
        $Exc.Add('Destination Port Range')
        $Exc.Add('NICs')
        $Exc.Add('Subnets')
        $Exc.Add('Orphaned')

        if ($InTag) {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value')
        }

        # $ExcelVar |
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc |
        # Export-Excel -Path $File -WorksheetName 'Network Security Groups' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style


        <######## Insert Column comments and documentations here following this model.  See StoraceAcc.ps1 for samples #########>


    }
}
