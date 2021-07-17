#region Setup
Import-Module 'C:\GitHub Repository\Presentations\Object Fomatting\Module\1.0.1\PSUtilities.psd1'

# This is used to connect to Exchange online for the demo. This line can be commented out.
3 | Start-connection
$ExoSes = Get-PSSession
$ExoSb = { Get-Mailbox }
Invoke-Command -Session $ExoSes -ScriptBlock $Exosb -AsJob # Exchange

$LocalSes = New-PSSession -Computer 192.168.1.4
$LocalSb = { Get-Process | Select-Object -First 15 }
Start-Job -Name MyBgJob -ScriptBlock $LocalSb

Invoke-Command -Session $LocalSes -ScriptBlock { Get-Date } -AsJob # Local
#Workflow HelloWorld { "Hello World" }; HelloWorld -AsJob # Workflow is not supported in PowerShell 6+. 

$jobs = getjt
Remove-Module PowerShellUtilities
Clear-Host
#endregion Setup

#region Object Types
# Create a new object with Select-Object
$process = Get-Process | Where-Object {$_.Handles –gt 50} | Sort-Object handles | Select-Object -First 2
$process

# TypeName:	System.Diagnostics.Process
Clear-Host
$process[0] | Get-Member -Force |
Where-Object { ($_.MemberType -eq 'Property') -or ($_.MemberType -eq 'Method') -or ($_.MemberType -eq 'Event') } |
Group-Object MemberType | Format-Table Name, Count

# In-depth view of the object
$process | Get-Member

# PowerShell Object Formatting Hierarchy - Both are hidding properties and can be exposed by using the Get-Member with the -Force parameter
Clear-Host
$process | Get-Member -Force | Where-Object { ($_.Name -eq 'pstypenames') -or ($_.Name -eq 'PSStandardMembers') }  

# Defines the Object Type
$process.pstypenames
# https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/
$process[0].PSStandardMembers.DefaultDisplayPropertySet
#endregion Object Types

#region Demo 1
# TIP on collection expansion!
# Invoke-Item $PSHome\en-us\about_Preference_Variables.help.txt
$FormatEnumerationLimit
$jobs[1].data | Select-Object -First 5 Name, AddressListMembership | Format-Table
$FormatEnumerationLimit = 15
$jobs[1].data | Select-Object -First 5 Name, AddressListMembership | Format-Table
$FormatEnumerationLimit = 4
#endregion Demo 1

# Demo 2 - Default-Out and formatting - Reference slide deck

#region Demo 3 
# TIP on Select-Object and why not to use it!!!
$jobs[1].data
$selectedData = $jobs[1].data | Select-Object | Where-Object Name -eq blocked
$selectedData
# Look what happened!!!
$selectedData.pstypenames
#endregion Demo 3 

#region Demo 4
# PowerShell Pipelinging and how PowerShell formats objects

# $PSHome = C:\Windows\System32\WindowsPowerShell\v1.0
Clear-Host
Get-ChildItem $PSHome/*format*.ps1xml
Get-ChildItem $PSHome/*type*.ps1xml
#endregion Demo 4 

#region Demo 5
# file types
Notepad $PSHome/dotnettypes.format.ps1xml
Notepad $PSHome/types.ps1xml

# Custom object creation - Need to link to view
# NOTE Custom object creation - Need to link to view
Clear-Host
$myCustomObject = [PSCustomObject]@{
    FirstName = 'PowerShell'
    LastName  = 'User'
    Date      = [DateTime]((get-date) -f '%r' -split " ")[0]
    Time      = ((get-date) -f '%r' -split " ")[1]
    City      = 'Charlotte'
    State     = 'NC'
    Job       = 'PowerShell Programmer'
    Company   = 'Software Company'
}

Clear-Host
$myCustomObject | Get-Member
$myCustomObject | Get-Member -Force
$myCustomObject.pstypenames
#endregion Demo 5

#region Demo 6 
# Ways to extend object with PSTypeNames
# Method 1 - Create your [PSCustomObject] with PSTypeName = 'Some Object'
$myCustomObject1 = [PSCustomObject]@{
    PSTypeName = 'myCustomObject1'
}
$myCustomObject1.pstypenames

# Method 2 - Add-Member
$myCustomObject | Add-member -TypeName myCustomObject
Clear-Host
$myCustomObject.pstypenames

# Method 3 - PSTypeNames.Insert
$myCustomObject3 = [PSCustomObject]@{
    Name = 'Dave'
}
$myCustomObject3.pstypenames.Insert(1, "myCustomObject3")
Clear-Host
$myCustomObject3.pstypenames

# NOTE: Add the type: Remove the type: $myCustomobject.pstypenames.Remove('myCustomObject')
# Update the property sets to reflect the changes - We will extended the DefaultDisplayProperties
# DefaultDisplayPropertertySet which provides a set of properties that should be displayed if there isn’t a view defined.
Clear-Host
$myCustomObject
$myCustomObject.pstypenames[0]
Update-TypeData -TypeName myCustomObject -DefaultDisplayPropertySet FirstName, LastName -DefaultDisplayProperty FirstName -DefaultKeyPropertySet CustomProperties -Force
$myCustomObject
$myCustomObject | Get-Member -Force

# The data still exists
Clear-Host
"First Name: {0}`nLast Name: {1}`nDate: {2}`nTime: {3}`nCity: {4}`nState: {5}`nJob: {6}`nCompany: {7}" -f $myCustomObject.FirstName,
$myCustomObject.LastName, $myCustomObject.Date, $myCustomObject.Time, $myCustomObject.City,
$myCustomObject.State, $myCustomObject.Job, $myCustomObject.Company
#endregion Demo 6

#region Demo 7
# Job format creation
Notepad 'c:\temp\MyCustomObject.format.ps1xml'
Update-FormatData -AppendPath 'c:\temp\MyCustomObject.format.ps1xml'
$myCustomObject

# KEY DIFFERENCE between FT and FL (two views exist now!)
$myCustomObject | Format-List
$myCustomObject.PSStandardMembers | Get-Member
#endregion Demo 7

#region Demo 8 
# Create a new format.ps1xml
Clear-Host
Get-TypeData -TypeName *job*
Get-FormatData -TypeName System.Management.Automation.Job | Export-FormatData -Path c:\temp\jobsxml.ps1xml

# Credit to Bruce Payette for this AWSESOME function!! - Windows PowerShell in Action
Format-XmlDocument -Path C:\temp\jobsxml.ps1xml -BypassEncodingCheck | clip | Notepad

# Demo module formats - how it all works
Clear-Host
Get-Job
Get-JobWithFormat

Clear-Host
Get-PSSession
Get-SessionWithFormat
$ses0 = Get-PSSession -id 1
$ses0 | Format-List
$ses1 = Get-SessionWithFormat
$ses1[0] | Format-List
#endregion Demo 8 