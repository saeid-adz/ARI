<#
.Synopsis
Security Center Module

.DESCRIPTION
This script process and creates the Security Center sheet based on securityresources. 

.Link
https://github.com/microsoft/ARI/Extras/SecurityCenter.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 

If ($Task -eq 'Processing')
{
    $obj = ''
    $tmp = @()

    $Security = $Security | Where-Object {$_.recommendationState -eq "Unhealthy"}

    foreach ($1 in $Security) {

       

        $obj = @{
            'Subscription'           = $1.subscriptionId;
            'TenantId'               = $1.tenantId;
            'RecommendationName'     = $1.recommendationName;
            'description'            = $1.description;
            'recommendationState'    = $1.recommendationState;
            'recommendationSeverity' = $1.recommendationSeverity;
            'remediationDescription' = $1.remediationDescription;
            'UserImpact'             = $1.userImpact;
            'category'               = [string]$1.category;
            'RemediationEffort'      = $1.implementationEffort;
            'Threats'                = [string]$1.threats;
            'link'                   = "https://"+$1.portalLink
        }    
        $tmp += $obj
    }
    $tmp
    DataSource-Management -TableName $ModName -tmp $tmp 
}
else 
{    
    <#
    $condtxtsec = $(New-ConditionalText High -Range G:G
    New-ConditionalText High -Range L:L)

    $Sec | 
    ForEach-Object { [PSCustomObject]$_ } | 
    Select-Object 'Subscription',
    'Resource Group',
    'Resource Type',
    'Resource Name',
    'Categories',
    'Control',
    'Severity',
    'Status',
    'Remediation',
    'Remediation Effort',
    'User Impact',
    'Threats' | 
    Export-Excel -Path $File -WorksheetName 'SecurityCenter' -AutoSize -MaxAutoSizeRows 100 -MoveToStart -TableName 'SecurityCenter' -TableStyle $tableStyle -ConditionalText $condtxtsec -KillExcel
#>
}