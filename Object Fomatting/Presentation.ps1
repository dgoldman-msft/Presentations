return

#Setup
3 | Start-connections
$ExoSes = Get-PSSession
$ExoSb = { Get-Mailbox }
Invoke-Command -Session $ExoSes -ScriptBlock $Exosb -AsJob # Exchange

$LocalSes = New-PSSession -Computer 192.168.1.4
$LocalSb = { Get-Process | Select-Object -First 15 }
Start-Job -Name MyBgJob -ScriptBlock $LocalSb

Invoke-Command -Session $LocalSes -ScriptBlock { Get-Date } -AsJob # Local
Workflow HelloWorld { "Hello World" }; HelloWorld -AsJob

# Demo object types
# TypeName:	System.Diagnostics.Process
Get-Process | Get-Member | Select-Object -First 1
Get-Process | Select-Object -First 5

$process = Get-Process | Select-Object -First 1
$process.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames
$FormatEnumerationLimit

# Demo - $PSHome = C:\Windows\System32\WindowsPowerShell\v1.0
cls
Get-ChildItem $PSHome/*format*.ps1xml
Get-ChildItem $PSHome/*type*.ps1xml

# Demo - file types
Notepad $PSHome/dotnettypes.format.ps1xml
Notepad $PSHome/types.ps1xml

# Demo - Custom object creation
$myCustomObject = [PSCustomObject]@{
    FirstName = 'Dave'
    LastName = 'Goldman'
    Date = ((get-date) -f '%r' -split " ")[0]
    Time = ((get-date) -f '%r' -split " ")[1]
    City = 'Charlotte'
    State = 'North Carolina'
    Job = 'Engineer'
    Company = 'Big Software Company'}

cls
$myCustomObject | Get-Member
$myCustomObject | Get-Member -Force

#Demo - Ways to exttend object with PSTypeNames
#Method 1 - Create your [PSCustomObject] with PSTypeName = 'Some Object'
$myCustomObject = [PSCustomObject]@{
    PSTypeName = 'YourObjectName'
    FirstName = 'Dave'
    LastName = 'Goldman'}

# Method 2 - Add-Member
$myCustomObject | Add-member -TypeName myCustomObject
$myCustomObject.pstypenames

# Method 3 - PSTypeNames.Insert
$myCustomObject.pstypenames.Insert(0, "MyCustomObject")
# NOTE: Add the type: Remove the type: $myCustomobject.pstypenames.Remove('myCustomObject')

$myCustomObject

# Update the property sets to reflect the changes - We will extended the DefaultDisplayProperties
cls
Update-TypeData -TypeName MyCustomObject -DefaultDisplayPropertySet Name, Company -DefaultDisplayProperty Name -DefaultKeyPropertySet CustomProperties -Force
$myCustomObject

"First Name:{0}`nLast Name:{1}`nCity:{2}`nState:{3}" -f $myCustomObject.FirstName, $myCustomObject.LastName, $myCustomObject.City, $myCustomObject.State
$myCustomObject | Get-Member -MemberType NoteProperty

# Demo - Job format creation
Get-Content -path 'c:\temp\MyCustomObject.format.ps1xml' | clip | Notepad
Update-FormatData -AppendPath 'c:\temp\MyCustomObject.format.ps1xml'
$myCustomObject