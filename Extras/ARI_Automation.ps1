
<######################################################### Functions ######################################################################>

############################> Send to EndPoint ############################>

function DataSource-Management {

    param (
    [Parameter(Mandatory=$true)]
        [String]$TableName,

    [Parameter(Mandatory=$true)]
        [array]$tmp
    )


    


    # Run the query to check if the table exists
    $query = "IF OBJECT_ID('$TableName', 'U') IS NOT NULL SELECT 1 ELSE SELECT 0"
    $tableExist = (Invoke-Sqlcmd -Query $query -ConnectionString $connectionString).Column1

    # Assign the value of $table based on the query result
    if($tableExist -eq 1) {
        $table = $true
    } else {
        $table = $false
    }

    # Tabele management condition
    if($table) {

        $data = $tmp
        
        #$columns = ($data[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
        $columns = $data[0].keys
        foreach ($row in $data) {
            $values = ""
            foreach ($col in $columns) {
                $values += "'" + $row.$col + "',"
            }
            $values = $values.Substring(0,$values.Length-1)
            $query = "INSERT INTO $tableName ($($columns -join ',')) VALUES ($values)"
            Invoke-Sqlcmd -Query $query -ConnectionString $connectionString
        }        

    } else {

        $data = $tmp

        #$columns = ($data[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
        $columns = $data[0].keys

        # Create the columns string
        $columnString = ""
        foreach ($col in $columns) {
            $columnString += "[$col] NVARCHAR(MAX),"
        }


        # Remove the last comma from the column string
        $columnString = $columnString.Substring(0,$columnString.Length-1)

        # Create the table
        $query = "CREATE TABLE $tableName ($columnString)"
        Invoke-Sqlcmd -Query $query -ConnectionString $connectionString

        # Insert the data
        foreach ($row in $data) {
            $values = ""
            foreach ($col in $columns) {
                $values += "'" + $row.$col + "',"
            }
            $values = $values.Substring(0,$values.Length-1)
            $query = "INSERT INTO $tableName ($($columns -join ',')) VALUES ($values)"
            Invoke-Sqlcmd -Query $query -ConnectionString $connectionString
        }

    }
    
}



<######################################################### SCRIPT ######################################################################>



Connect-AzAccount -Identity -MaxContextPopulation 1000


$aristg = $STGCTG

$TableStyle = "Light20"

$Date = get-date -Format "yyyy-MM-dd"
$DateStart = get-date

$File = ("Report_"+$Date+".xlsx")



$Resources = @()
$Advisories = @()
$Security = @()
$Subscriptions = ''

$Repo = 'https://github.com/saeid-adz/ARI/tree/main/Modules'
$RawRepo = 'https://raw.githubusercontent.com/saeid-adz/ARI/main'

<######################################################### ADVISORY EXTRACTION ######################################################################>

Write-Output 'Extracting Advisories'
    Connect-AzAccount -Identity -MaxContextPopulation 1000
    $AdvSize = Search-AzGraph -Query "advisorresources | summarize count()"
    $AdvSizeNum = $AdvSize.'count_'

    if ($AdvSizeNum -ge 1) {
        $Loop = $AdvSizeNum / 1000
        $Loop = [math]::ceiling($Loop)
        $Looper = 0
        $Limit = 1

        while ($Looper -lt $Loop) 
            {
                $Looper ++
                $Advisor = Search-AzGraph -Query "advisorresources | order by id asc" -skip $Limit -first 1000
                $Advisories += $Advisor
                Start-Sleep 2
                $Limit = $Limit + 1000
            }
    } 


<######################################################### Secruity EXTRACTION ######################################################################>

    $SecResSize = Search-AzGraph -Query "securityresources | summarize count()"
    $SecResSizeNum = $SecResSize.'count_'

    if ($SecResSizeNum -ge 1) {
        $Loop = $SecResSizeNum / 1000
        $Loop = [math]::ceiling($Loop)
        $Looper = 0
        $Limit = 1

        while ($Looper -lt $Loop) 
            {
                $Looper ++
                $SecRes = Search-AzGraph -Query "SecurityResources | where type == 'microsoft.security/assessments' | extend resourceId=id, recommendationId=name, recommendationName=properties.displayName, source=properties.resourceDetails.Source, recommendationState=properties.status.code, description=properties.metadata.description, assessmentType=properties.metadata.assessmentType, remediationDescription=properties.metadata.remediationDescription, policyDefinitionId=properties.metadata.policyDefinitionId, implementationEffort=properties.metadata.implementationEffort, recommendationSeverity=properties.metadata.severity, category=properties.metadata.categories, userImpact=properties.metadata.userImpact, threats=properties.metadata.threats, portalLink=properties.links.azurePortal | project tenantId, subscriptionId, resourceId, recommendationName, recommendationId, recommendationState, recommendationSeverity, description, remediationDescription, assessmentType, policyDefinitionId, implementationEffort, userImpact, category, threats, source, portalLink" -skip $Limit -first 1000
                $Security += $SecRes
                Start-Sleep 2
                $Limit = $Limit + 1000
            }
    } 

$Subscriptions = Get-AzSubscription #Get-AzContext -ListAvailable | Where-Object {$_.Subscription.State -ne 'Disabled'}
#$Subscriptions = $Subscriptions.Subscription

<######################################################### RESOURCE EXTRACTION ######################################################################>

Write-Output 'Extracting Resources'
 
    Foreach ($Subscription in $Subscriptions) {

        $SUBID = $Subscription.id
        Select-AzSubscription -Subscription $SUBID | Out-Null #Set-AzContext -Subscription $SUBID | Out-Null
                    
        $EnvSize = Search-AzGraph -Query "resources | where subscriptionId == '$SUBID' and strlen(properties) < 123000 | summarize count()"
        $EnvSizeNum = $EnvSize.count_
                        
        if ($EnvSizeNum -ge 1) {
            $Loop = $EnvSizeNum / 1000
            $Loop = [math]::ceiling($Loop)
            $Looper = 0
            $Limit = 1
    
            while ($Looper -lt $Loop) {
                $Resource0 = Search-AzGraph -Query "resources | where subscriptionId == '$SUBID' and strlen(properties) < 123000 | order by id asc" -skip $Limit -first 1000
                $Resources += $Resource0
                Start-Sleep 2
                $Looper ++
                $Limit = $Limit + 1000
            }
        }
    }   
    
$ExtractionRunTime = get-date -Format  "yyyy-MM-dd HH:mm:ss"

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Support.json')
$Unsupported = $ModuSeq | ConvertFrom-Json


<######################################################### ADVISORY JOB ######################################################################>


Write-Output ('Starting Advisory Job')

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Start-Job -Name 'Advisory' -ScriptBlock $ScriptBlock -ArgumentList $Advisories, 'Processing' , $File

            
<######################################################### SUBSCRIPTIONS JOB ######################################################################>

Write-Output ('Starting Subscription Job')

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Start-Job -Name 'Subscriptions' -ScriptBlock $ScriptBlock -ArgumentList $Subscriptions, $Resources, 'Processing' , $File


<######################################################### RESOURCES ######################################################################>


Write-Output ('Starting Resources Processes')

$Modules = @()
Write-Output ('Running Online, Gethering List Of Modules for Compute.')
$OnlineRepoComp = Invoke-WebRequest -Uri ($Repo + '/Compute') -UseBasicParsing
$RepoComp = $OnlineRepoComp.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoComp.href
Write-Output ('Running Online, Gethering List Of Modules for Networking.')
$OnlineRepoNetworking = Invoke-WebRequest -Uri ($Repo + '/Networking') -UseBasicParsing
$RepoNetwork = $OnlineRepoNetworking.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoNetwork.href
Write-Output ('Running Online, Gethering List Of Modules for Database.')
$OnlineRepoDB = Invoke-WebRequest -Uri ($Repo + '/Data') -UseBasicParsing
$RepoData = $OnlineRepoDB.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoData.href
Write-Output ('Running Online, Gethering List Of Modules for Infrastructure.')
$OnlineRepoInfra = Invoke-WebRequest -Uri ($Repo + '/Infrastructure') -UseBasicParsing
$RepoInfra = $OnlineRepoInfra.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoInfra.href
Write-Output ('Running Online, Gethering List Of Modules for Other.')
$OnlineRepoOther = Invoke-WebRequest -Uri ($Repo + '/Other') -UseBasicParsing
$RepoOther = $OnlineRepoOther.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoOther.href

foreach ($Module in $Modules) 
    {
        Write-Output $Module
        $SmaResources = @{}

        $Modul = $Module.split('/')
        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
        $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Modules/' + $Modul[6] + '/' + $Modul[7])
        
        $ScriptBlock = [Scriptblock]::Create($ModuSeq)

        $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing'

        Write-Output ('Resources ('+$ModName+'): '+$SmaResources[$ModName].count)

        Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot,$null,$InTag,$null,'Reporting',$File,$SmaResources,$TableStyle,$Unsupported | Out-Null

    }


<######################################################### ADVISORY REPORTING ######################################################################>

get-job -Name 'Advisory' | Wait-Job | Out-Null

$Adv = Receive-Job -Name 'Advisory'

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,'Reporting',$file,$Adv,$TableStyle

<######################################################### SUBSCRIPTIONS REPORTING ######################################################################>

get-job -Name 'Subscriptions' | Wait-Job | Out-Null

$AzSubs = Receive-Job -Name 'Subscriptions'

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,$null,'Reporting',$file,$AzSubs,$TableStyle

<######################################################### CHARTS ######################################################################>
<#
$ReportingRunTime = get-date

$ExtractionRunTime = (($ExtractionRunTime) - ($DateStart))

$ReportingRunTime = (($ReportingRunTime) - ($DateStart))

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Charts.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

$FileFull = ((Get-Location).Path+'\'+$File)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $FileFull,'Light20','Azure Automation',$Subscriptions,$Resources.Count,$ExtractionRunTime,$ReportingRunTime
#>
<######################################################### UPLOAD FILE ######################################################################>

Write-Output 'Uploading Excel File to Storage Account'

Set-AzStorageBlobContent -File $File -Container $aristg -Context $Context | Out-Null
if($Diagram){Set-AzStorageBlobContent -File $DDFile -Container $aristg -Context $Context | Out-Null}

Write-Output 'Completed'