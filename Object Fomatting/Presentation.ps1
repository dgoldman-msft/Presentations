return

# Setup
3 | Start-connections
$ExoSes = Get-PSSession
$ExoSb = { Get-Mailbox }
Invoke-Command -Session $ExoSes -ScriptBlock $Exosb -AsJob # Exchange

$LocalSes = New-PSSession -Computer 192.168.1.4
$LocalSb = { Get-Process | Select-Object -First 15 }
Start-Job -Name MyBgJob -ScriptBlock $LocalSb

Invoke-Command -Session $LocalSes -ScriptBlock { Get-Date } -AsJob # Local
Workflow HelloWorld { "Hello World" }; HelloWorld -AsJob
cls

# Demo - Object types
# TypeName:	System.Diagnostics.Process
Get-Process | Get-Member -Force
Get-Process | Select-Object -First 5

$process = Get-Process | Select-Object -First 1
$process.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames

# Demo - Pipeline
$FormatEnumerationLimit

# Demo - $PSHome = C:\Windows\System32\WindowsPowerShell\v1.0
cls
Get-ChildItem $PSHome/*format*.ps1xml
Get-ChildItem $PSHome/*type*.ps1xml

# Demo - file types
Notepad $PSHome/dotnettypes.format.ps1xml
Notepad $PSHome/types.ps1xml

# Demo - Custom object creation
cls
$myCustomObject = [PSCustomObject]@{
    FirstName = 'Dave'
    LastName = 'Goldman'
    Date = [DateTime]((get-date) -f '%r' -split " ")[0]
    Time = ((get-date) -f '%r' -split " ")[1]
    City = 'Charlotte'
    State = 'North Carolina'
    Job = 'Engineer'
    Company = 'Big Software Company'}

cls
$myCustomObject | Get-Member
$myCustomObject | Get-Member -Force
$myCustomObject.pstypenames

#Demo - Ways to exttend object with PSTypeNames
#Method 1 - Create your [PSCustomObject] with PSTypeName = 'Some Object'
$myCustomObject = [PSCustomObject]@{
    PSTypeName = 'myCustomObject'
    Key = 'Value'}

# Method 2 - Add-Member
$myCustomObject | Add-member -TypeName myCustomObject
$myCustomObject.pstypenames

# Method 3 - PSTypeNames.Insert
$myCustomObject.pstypenames.Insert(0, "myCustomObject")

# NOTE: Add the type: Remove the type: $myCustomobject.pstypenames.Remove('myCustomObject')
$myCustomObject.pstypenames | Get-Member
$myCustomObject
$myCustomObject.pstypenames

# Update the property sets to reflect the changes - We will extended the DefaultDisplayProperties
cls
Update-TypeData -TypeName MyCustomObject -DefaultDisplayPropertySet Name, Company -DefaultDisplayProperty Name -DefaultKeyPropertySet CustomProperties -Force
$myCustomObject
$myCustomObject | gm -Force

cls
"First Name: {0}`nLast Name: {1}`nDate: {2}`nTime: {3}`nCity: {4}`nState: {5}`nJob: {6}`nCompany: {7}" -f $myCustomObject.FirstName,
$myCustomObject.LastName, $myCustomObject.Date, $myCustomObject.Time, $myCustomObject.City,
$myCustomObject.State, $myCustomObject.Job, $myCustomObject.Company
$myCustomObject | Get-Member -MemberType NoteProperty

# Demo - Job format creation
Notepad 'c:\temp\MyCustomObject.format.ps1xml'
Update-FormatData -AppendPath 'c:\temp\MyCustomObject.format.ps1xml'
$myCustomObject

# Demo: Create a new format.ps1xml
foreach($job in Get-Job){ $job.GetType() | Select-Object Name, BaseType }
Get-TypeData -TypeName *job*

Get-FormatData -TypeName System.Management.Automation.Job | Export-FormatData -Path c:\temp\jobsxml.ps1xml
Format-XmlDocument -Path C:\temp\jobsxml.ps1xml | clip | Notepad

cls
Get-Job