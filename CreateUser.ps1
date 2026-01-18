 #=============================================
# 1. Azure Entra ID & RBAC
# =============================================
# Create Users
#https://www.powershellgallery.com/packages/Microsoft.Graph.Users/2.34.0
Connect-AzureAD
 Install-Module Microsoft.Graph
 Update-Module Microsoft.Graph
 Get-Module -ListAvailable -Name *graph*
 Get-AzTenant
 Disconnect-MgGraph
 $TenantID = "XXX"
connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All, "Directory.ReadWrite.All" -NoWelcome
$TenantID = "***"
 Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All
Get-MgContext
Get-MgUser -All
$PasswordProfile = @{
    Password = 'TempP@ssword123'
    ForceChangePasswordNextSignIn = $true
}


 New-MgUser -DisplayName "John Contributor" -PasswordProfile $PasswordProfile -UserPrincipalName "john.contributor@intunem3652026outlook.onmicrosoft.com" -MailNickName "johncontributor" -AccountEnabled:$true -UsageLocation "US"


 #=============================================
 # 2. standardized device naming help your organization
 # =============================================
 #Before:
#John's Laptop
#DESKTOP-ABC123 
#Sarah-PC
#After:
•#LinkedIn-D57642
#LinkedIn-E12345
#LinkedIn-F98765

#The PowerShell script:

$Devices = Get-MgDeviceManagementManagedDevice | Where-Object {$_.DeviceName -notlike "LinkedIn-*"}
foreach ($Device in $Devices) {
 $NewName = "LinkedIn-$($Device.SerialNumber)"
 Update-MgDeviceManagementManagedDevice -ManagedDeviceId $Device.Id -DeviceName $NewName
}
#Finds all devices WITHOUT your naming standard
#Creates new name: CompanyName-SerialNumber
#Updates each device automatically in Intune