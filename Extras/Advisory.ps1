<#
.Synopsis
Advisory Module

.DESCRIPTION
This script process and creates the Advisory sheet based on advisorresources. 

.Link
https://github.com/microsoft/ARI/Extras/Advisory.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

#>

param($Advisories, $Task ,$File, $Adv, $TableStyle)

If ($Task -eq 'Processing')
{
    $obj = ''
    $tmp = @()

    foreach ($1 in $Advisories) 
        {
            if($1)
                {
                    $data = $1.PROPERTIES

                    if($null -eq $data.extendedProperties.annualSavingsAmount){$Savings = 0}Else{$Savings = $data.extendedProperties.annualSavingsAmount}
                    if($null -eq $data.extendedProperties.savingsCurrency){$SavingsCurrency = 'USD'}Else{$SavingsCurrency = $data.extendedProperties.savingsCurrency}
                    $obj = @{
                        'TenantId'               = $1.tenantId
                        'SubscriptionId'         = $1.subscriptionId
                        'ResourceGroup'          = $1.resourceGroup;
                        'AffectedResourceType'   = $data.impactedField;
                        'Name'                   = $data.impactedValue;
                        'Category'               = $data.category;
                        'Impact'                 = $data.impact;
                        #'Score'                  = $data.extendedproperties.score;
                        'Problem'                = $data.shortDescription.problem;
                        'SavingsCurrency'        = $SavingsCurrency;
                        'AnnualSavings'          = $Savings;
                        'SavingsRegion'          = $data.extendedProperties.location;   
                        'CurrentSKU'             = $data.extendedProperties.currentSku;
                        'TargetSKU'              = $data.extendedProperties.targetSku
                    }    
                    $tmp += $obj

                    
                }
        }
    $tmp

    DataSource-Management -TableName $ModName -tmp $tmp 
}
Else
{
    <#
    $condtxtadv = $(New-ConditionalText High -Range E:E
                New-ConditionalText Security -Range D:D -BackgroundColor Wheat)

    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '#,##0.00' -Range H:H 

        
            $Adv |
            ForEach-Object { [PSCustomObject]$_ } | 
            Select-Object 'TenantId',
            'SubscriptionId',
            'ResourceGroup',
            'Affected Resource Type',
            'Name', 
            'Category',
            'Impact',
            #'Score',
            'Problem',
            'Savings Currency',
            'Annual Savings',
            'Savings Region',
            'Current SKU',
            'Target SKU' |
            Export-Excel -Path $File -WorksheetName 'Advisory' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureAdvisory' -MoveToStart -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtadv -KillExcel 
#>
}
