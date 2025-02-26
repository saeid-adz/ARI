<#
.Synopsis
Inventory for Azure Cache for Redis

.DESCRIPTION
This script consolidates information for all microsoft.cache/redis resource provider in $Resources variable. 
Excel Sheet Name: RedisCache

.Link
https://github.com/microsoft/ARI/Modules/Data/RedisCache.ps1

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

    $RedisCache = @()
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redis' }
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redisenterprise' }

    if($RedisCache)
        {
            $tmp = @()

            foreach ($1 in $RedisCache) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $PvtEndP = if($data.privateEndpointConnections.properties.privateEndpoint.id){$data.privateEndpointConnections.properties.privateEndpoint.id.split('/')[8]}else{'None'}
                if ($1.ZONES) { $Zones = $1.ZONES }else { $Zones = 'Not Configured' }
                if ([string]::IsNullOrEmpty($data.minimumTlsVersion)){$MinTLS = 'Default'}Else{$MinTLS = "TLS $($data.minimumTlsVersion)"}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                    = $1.id;
                            'Subscription'          = $sub1.Name;
                            'ResourceGroup'         = $1.RESOURCEGROUP;
                            'Name'                  = $1.NAME;
                            'Location'              = $1.LOCATION;
                            'Zone'                  = $Zones;
                            'Version'               = $data.redisVersion;
                            'PublicNetworkAccess' = $data.publicNetworkAccess;
                            'FQDN'                  = $data.hostName;
                            'Port'                  = $data.port;
                            'EnableNonSSLPort'   = $data.enableNonSslPort;
                            'MinimumTLSVersion'   = $MinTLS;
                            'SSLPort'              = $data.sslPort;
                            'PrivateEndpoint'      = $PvtEndP;
                            'Sku'                   = $data.sku.name;
                            'Capacity'              = $data.sku.capacity;
                            'Family'                = $data.sku.family;
                            'MaxFragMemReserved' = $data.redisConfiguration.'maxfragmentationmemory-reserved';
                            'MaxMemReserved'      = $data.redisConfiguration.'maxmemory-reserved';
                            'MaxMemoryDelta'      = $data.redisConfiguration.'maxmemory-delta';
                            'MaxClients'           = $data.redisConfiguration.'maxclients';
                            'ResourceU'            = $ResUCount;
                            'TagName'              = [string]$Tag.Name;
                            'TagValue'             = [string]$Tag.Value;
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

    if ($SmaResources.RedisCache) {

        $TableName = ('RedisCacheTable_'+($SmaResources.RedisCache.id | Select-Object -Unique).count)
        $condtxt = @()
        $condtxt += New-ConditionalText "Not Configured" -Range E:E
        $condtxt += New-ConditionalText Default -Range K:K
        $condtxt += New-ConditionalText 1.0 -Range K:K
        $condtxt += New-ConditionalText 1.1 -Range K:K
        $condtxt += New-ConditionalText TRUE -Range J:J
        $condtxt += New-ConditionalText VERDADEIRO -Range J:J

        $Style = @()        
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0.0 -Range K:K
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0 -Range A:J
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0 -Range L:Z
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')                    
        $Exc.Add('Location')           
        $Exc.Add('Zone')                    
        $Exc.Add('Version')                 
        $Exc.Add('Public Network Access')
        $Exc.Add('FQDN')                    
        $Exc.Add('Port')                    
        $Exc.Add('Enable Non SSL Port')
        $Exc.Add('Minimum TLS Version')         
        $Exc.Add('SSL Port')   
        $Exc.Add('Private Endpoint')             
        $Exc.Add('Sku')                     
        $Exc.Add('Capacity')
        $Exc.Add('Family')                  
        $Exc.Add('Max Frag Mem Reserved')   
        $Exc.Add('Max Mem Reserved')        
        $Exc.Add('Max Memory Delta')        
        $Exc.Add('Max Clients')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.RedisCache

        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Redis Cache' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style
    }
    <######## Insert Column comments and documentations here following this model #########>
}
