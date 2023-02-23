<#
.Synopsis
Inventory for Azure RedHat OpenShift

.DESCRIPTION
This script consolidates information for all microsoft.redhatopenshift/openshiftclusters resource provider in $Resources variable. 
Excel Sheet Name: ARO

.Link
https://github.com/microsoft/ARI/Modules/Compute/ARO.ps1

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

    $ARO = $Resources | Where-Object { $_.TYPE -eq 'microsoft.redhatopenshift/openshiftclusters' }

    <######### Insert the resource Process here ########>

    if($ARO)
        {
            $tmp = @()
            foreach ($1 in $ARO) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'ResourceGroup'       = $1.RESOURCEGROUP;
                            'Clusters'             = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'AROVersion'          = $data.clusterProfile.version;
                            'ARODomain'           = $data.clusterProfile.domain;
                            'OutboundType'        = $data.networkProfile.outboundType;
                            'IngressProfileName' = $data.ingressProfiles.name;
                            'IngressProfiletype' = $data.ingressProfiles.visibility;
                            'IngressProfileIP'   = $data.ingressProfiles.ip;
                            'APIServertype'      = $data.apiserverProfile.visibility;
                            'APIServerURL'       = $data.apiserverProfile.url;
                            'APIServerIP'        = $data.apiserverProfile.ip;
                            'DockerPodCidr'      = $data.networkProfile.podCidr;
                            'ServiceCidr'         = $data.networkProfile.serviceCidr;
                            'ConsoleURL'          = $data.consoleProfile.url;                   
                            'MasterSKU'           = $data.masterProfile.vmSize;
                            'MastervNET'          = if($data.masterProfile.subnetId){$data.masterProfile.subnetId.split("/")[8]};
                            'MasterSubnet'        = if($data.masterProfile.subnetId){$data.masterProfile.subnetId.split("/")[10]};                    
                            'WorkerSKU'           = $data.workerProfiles.vmSize | Select-Object -Unique;        
                            'WorkerDiskSize'      = $data.workerProfiles.diskSizeGB | Select-Object -Unique;        
                            'TotalWorkerNodes'   = $data.workerProfiles.count;        
                            'WorkervNET'          = $data.workerProfiles.subnetId | ForEach-Object { $_.split("/")[8] } | Select-Object -Unique; 
                            'WorkerSubnet'        = $data.workerProfiles.subnetId | ForEach-Object { $_.split("/")[10] } | Select-Object -Unique;       
                            'ResourceU'           = $ResUCount;
                            'TagName'             = [string]$Tag.Name;
                            'TagValue'            = [string]$Tag.Value;
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

    if ($SmaResources.ARO) {

        $TableName = ('AROTable_'+($SmaResources.ARO.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Clusters')         
        $Exc.Add('Location')             
        $Exc.Add('ARO Version')          
        $Exc.Add('ARO Domain')           
        $Exc.Add('Outbound Type')        
        $Exc.Add('Ingress Profile Name')
        $Exc.Add('Ingress Profile type') 
        $Exc.Add('Ingress Profile IP')   
        $Exc.Add('API Server type')      
        $Exc.Add('API Server URL')       
        $Exc.Add('API Server IP')        
        $Exc.Add('Docker Pod Cidr')      
        $Exc.Add('Service Cidr')         
        $Exc.Add('Console URL')                
        $Exc.Add('Master SKU')           
        $Exc.Add('Master vNET')          
        $Exc.Add('Master Subnet')                     
        $Exc.Add('Worker SKU')           
        $Exc.Add('Worker DiskSize')        
        $Exc.Add('Total Worker Nodes')   
        $Exc.Add('Worker vNET')          
        $Exc.Add('Worker Subnet')
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        $ExcelVar = $SmaResources.ARO 

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'ARO' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -Numberformat '0' -Style $Style
    
    }
}