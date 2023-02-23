<#
.Synopsis
Inventory for Azure Automation Account

.DESCRIPTION
This script consolidates information for all microsoft.automation/automationaccounts and  resource provider in $Resources variable. 
Excel Sheet Name: AutomationAcc

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/AutomationAcc.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $runbook = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts/runbooks'}
        $autacc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts'}

    <######### Insert the resource Process here ########>

    if($autacc)
        {
            $tmp = @()

            foreach ($0 in $autacc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $0.subscriptionId }
                $rbs = $runbook | Where-Object { $_.id.split('/')[8] -eq $0.name }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if ($null -ne $rbs) {
                    foreach ($1 in $rbs) {
                            foreach ($Tag in $Tags) {    
                                $data = $1.PROPERTIES
                                $obj = @{
                                    'ID'                       = $1.id;
                                    'Subscription'             = $sub1.Name;
                                    'ResourceGroup'           = $0.RESOURCEGROUP;
                                    'AutomationAccountName'  = $0.NAME;
                                    'AutomationAccountState' = $0.properties.State;
                                    'AutomationAccountSKU'   = $0.properties.sku.name;
                                    'Location'                 = $0.LOCATION;
                                    'RunbookName'             = $1.Name;
                                    'LastModifiedTime'       = ([datetime]$data.lastModifiedTime).tostring('MM/dd/yyyy hh:mm') ;
                                    'RunbookState'            = $data.state;
                                    'RunbookType'             = $data.runbookType;
                                    'RunbookDescription'      = $data.description;
                                    'JobCount'                = $data.jobCount;
                                    'ResourceU'               = $ResUCount;
                                    'TagName'                 = [string]$Tag.Name;
                                    'TagValue'                = [string]$Tag.Value;
                                    'Time'                 = $ExtractionRunTime
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }                        
                    }
                }
                else {
                        foreach ($Tag in $Tags) {  
                            $obj = @{
                                'ID'                       = $1.id;
                                'Subscription'             = $sub1.name;
                                'ResourceGroup'           = $0.RESOURCEGROUP;
                                'AutomationAccountName'  = $0.NAME;
                                'AutomationAccountState' = $0.properties.State;
                                'AutomationAccountSKU'   = $0.properties.sku.name;
                                'Location'                 = $0.LOCATION;
                                'RunbookName'             = $null;
                                'LastModifiedTime'       = $null;
                                'RunbookState'            = $null;
                                'RunbookType'             = $null;
                                'RunbookDescription'      = $null;
                                'JobCount'                = $null;
                                'ResourceU'               = $ResUCount;
                                'TagName'                 = [string]$Tag.Name;
                                'TagValue'                = [string]$Tag.Value;
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.AutomationAcc)
    {

        $TableName = ('AutAccTable_'+($SmaResources.AutomationAcc.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
        $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range K:K -Width 80 -WrapText 

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Automation Account Name')
        $Exc.Add('Automation Account State')
        $Exc.Add('Automation Account SKU')
        $Exc.Add('Location')
        $Exc.Add('Runbook Name')
        $Exc.Add('Last Modified Time')
        $Exc.Add('Runbook State')
        $Exc.Add('Runbook Type')
        $Exc.Add('Runbook Description')
        $Exc.Add('Job Count')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AutomationAcc  
            
        # $ExcelVar | 
        # ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        # Export-Excel -Path $File -WorksheetName 'Runbooks' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style, $StyleExt

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}