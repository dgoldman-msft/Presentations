#region Setup
3 | Start-connection
$ExoSes = Get-PSSession
$ExoSb = { Get-Mailbox }
Invoke-Command -Session $ExoSes -ScriptBlock $Exosb -AsJob # Exchange

$LocalSes = New-PSSession -Computer 192.168.1.4
$LocalSb = { Get-Process | Select-Object -First 15 }
Start-Job -Name MyBgJob -ScriptBlock $LocalSb

Invoke-Command -Session $LocalSes -ScriptBlock { Get-Date } -AsJob # Local
Workflow HelloWorld { "Hello World" }; HelloWorld -AsJob
$jobs = gjt
Clear-Host
#endregion Setup

#region - Object types
# TypeName:	System.Diagnostics.Process
(Get-Process | Get-Member).count
(Get-Process | Get-Member -force).count
(Get-Process | Get-Member -static).count

# Create a new object with Select-Object
$process = Get-Process | Select-Object -First 1

# PowerShell Object Hierarchy
#endregion Notes
$process | Get-Member -Force | where-object Name -like "ps*" 
$process.pstypenames

#Region Notes
# The magic sauce!!
# https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/
#endregion Demo
$process.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames
$process

# PowerShell Pipelinging and object control
# More information 
ii $PSHome\en-us\about_Preference_Variables.help.txt
$FormatEnumerationLimit
$jobs[1].data | Select-Object -First 5 Name, AddressListMembership | Format-Table
$FormatEnumerationLimit = 15
$jobs[1].data | Select-Object -First 5 Name, AddressListMembership | Format-Table
$FormatEnumerationLimit = 4
#endregion FormatEnumerationLimit

# Demo - $PSHome = C:\Windows\System32\WindowsPowerShell\v1.0
Clear-Host
Get-ChildItem $PSHome/*format*.ps1xml
Get-ChildItem $PSHome/*type*.ps1xml

# Demo - file types
ii $PSHome/dotnettypes.format.ps1xml
ii $PSHome/types.ps1xml

# Demo - Custom object creation 
Clear-Host
$myCustomObject = [PSCustomObject]@{
    FirstName = 'Dave'
    LastName  = 'Goldman'
    Date      = [DateTime]((get-date) -f '%r' -split " ")[0]
    Time      = ((get-date) -f '%r' -split " ")[1]
    City      = 'Charlotte'
    State     = 'NC'
    Job       = 'Sr. CE'
    Company   = 'Small Software Company'
}

Clear-Host
$myCustomObject | Get-Member
$myCustomObject | Get-Member -Force
$myCustomObject.pstypenames

# Demo - Ways to extend object with PSTypeNames
#region ExtendTypes
# Method 1 - Create your [PSCustomObject] with PSTypeName = 'Some Object'
$myCustomObject1 = [PSCustomObject]@{
    PSTypeName = 'myCustomObject1'
}
$myCustomObject1.pstypenames

# Method 2 - Add-Member
$myCustomObject | Add-member -TypeName myCustomObject
$myCustomObject.pstypenames

# Method 3 - PSTypeNames.Insert
$myCustomObject3 = [PSCustomObject]@{
    Key        = 'Value'
}
$myCustomObject3.pstypenames.Insert(0, "myCustomObject3")

# NOTE: Add the type: Remove the type: $myCustomobject.pstypenames.Remove('myCustomObject')
#region ExtendTypes

# Update the property sets to reflect the changes - We will extended the DefaultDisplayProperties
Clear-Host
Update-TypeData -TypeName myCustomObject -DefaultDisplayPropertySet FirstName, Company -DefaultDisplayProperty FirstName -DefaultKeyPropertySet CustomProperties -Force
$myCustomObject
$myCustomObject | Get-Member -Force

# The data still exists
Clear-Host
"First Name: {0}`nLast Name: {1}`nDate: {2}`nTime: {3}`nCity: {4}`nState: {5}`nJob: {6}`nCompany: {7}" -f $myCustomObject.FirstName,
$myCustomObject.LastName, $myCustomObject.Date, $myCustomObject.Time, $myCustomObject.City,
$myCustomObject.State, $myCustomObject.Job, $myCustomObject.Company

# Demo - Job format creation
Notepad 'c:\temp\MyCustomObject.format.ps1xml'
Update-FormatData -AppendPath 'c:\temp\MyCustomObject.format.ps1xml'
$myCustomObject
$myCustomObject | Format-List
$myCustomObject.PSStandardMembers | Get-Member

#NOTE: Point out the differnce between FT and FL
# Demo: Create a new format.ps1xml
foreach ($job in Get-Job) { $job.GetType() | Select-Object Name, BaseType }
Get-TypeData -TypeName *job*
Get-FormatData -TypeName System.Management.Automation.Job | Export-FormatData -Path c:\temp\jobsxml.ps1xml
Format-XmlDocument -Path C:\temp\jobsxml.ps1xml | clip | Notepad

# Demo module formats - how it all works
Clear-Host
Get-Job
Get-JobType

Clear-Host
Get-PSSession
Get-SessionType
$ses0 = Get-PSSession -id 1
$ses0 | Format-List
$ses1 = Get-SessionType
$ses1[0] | Format-List
