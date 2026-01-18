
# =============================================
# Azure Setup Automation Script
# =============================================
# Prerequisites:
# - Install Az module: Install-Module -Name Az -Scope CurrentUser -Force
# - Install AzureAD module: Install-Module -Name AzureAD -Scope CurrentUser -Force
# - Replace placeholders (<SubscriptionId>, <Domain>, <Email>) with actual values

# =============================================
# 1. Connect to Azure Account & Verify Subscription
# =============================================
Connect-AzAccount
Get-AzSubscription
Select-AzSubscription -SubscriptionId "<SubscriptionId>"

# =============================================
# 2. Management Groups & Governance Policies
# =============================================
# Create Management Group
New-AzManagementGroup -GroupId "RootManagementGroup" -DisplayName "Root Management Group"

# Apply Governance Policy (Allowed Locations)
$policyDefinition = New-AzPolicyDefinition -Name "AllowedLocations" -DisplayName "Allowed Locations" -PolicyType BuiltIn -PolicyRule '{"if":{"field":"location","notIn":["eastus","westus"]},"then":{"effect":"deny"}}'
New-AzPolicyAssignment -Name "AllowedLocationsAssignment" -Scope "/subscriptions/<SubscriptionId>" -PolicyDefinition $policyDefinition

# =============================================
# 3. Azure AD & RBAC
# =============================================
# 3a. Configure Azure AD Roles and Enable MFA
# =============================
# Note: MFA enforcement is done via Conditional Access policies in Azure AD portal.
# Assign a role to a user example:
# Get-AzRoleDefinition | Where-Object {$_.RoleName -eq "Contributor"}
# New-AzRoleAssignment -ObjectId <UserObjectId> -RoleDefinitionName "Contributor" -Scope "/subscriptions/<SubscriptionId>"
Connect-AzureAD

# Create Users
$user1 = New-AzureADUser -DisplayName "John Contributor" -UserPrincipalName "john.contributor@<Domain>.onmicrosoft.com" -AccountEnabled $true -PasswordProfile @{Password="TempP@ssword123"; ForceChangePasswordNextLogin=$true} -MailNickname "johncontributor"
$user2 = New-AzureADUser -DisplayName "Jane Reader" -UserPrincipalName "jane.reader@<Domain>.onmicrosoft.com" -AccountEnabled $true -PasswordProfile @{Password="TempP@ssword123"; ForceChangePasswordNextLogin=$true} -MailNickname "janereader"

# Assign RBAC Roles
New-AzRoleAssignment -ObjectId $user1.ObjectId -RoleDefinitionName "Contributor" -Scope "/subscriptions/<SubscriptionId>"
New-AzRoleAssignment -ObjectId $user2.ObjectId -RoleDefinitionName "Reader" -Scope "/subscriptions/<SubscriptionId>"

# =============================================
# 4. Security Policies & Monitoring
# =============================================
# Enable Security Center
Set-AzSecurityCenterSubscription -SubscriptionId "<SubscriptionId>" -Enable

# Enable Activity Log Alerts (example for resource deletion)
$actionGroup = New-AzActionGroup -Name "DefaultActionGroup" -ResourceGroupName "RG-Production" -ShortName "DefActGrp" -Receiver @{Name="AdminEmail"; EmailAddress="<Email>"}
New-AzActivityLogAlert -Name "ResourceDeletionAlert" -ResourceGroupName "RG-Production" -Scope "/subscriptions/<SubscriptionId>" -Condition @{Category="Administrative"; OperationName="Delete"} -ActionGroupId $actionGroup.Id

# =============================================
# 5. Resource Groups & Networking
# =============================================
New-AzResourceGroup -Name "RG-Production" -Location "WestUS"
New-AzResourceGroup -Name "RG-DevTest" -Location "WestUS"

# Create Virtual Network
New-AzVirtualNetwork -Name "VNet-Production" -ResourceGroupName "RG-Production" -Location "WestUS" -AddressPrefix "10.0.0.0/16" -Subnet @(@{Name="Subnet1";AddressPrefix="10.0.1.0/24"})

# =============================================
# 6. Cost Management & Optimization
# =============================================
New-AzConsumptionBudget -Name "MonthlyBudget" -Amount 200 -TimeGrain Monthly -StartDate (Get-Date) -EndDate (Get-Date).AddYears(1) -Category Cost -NotificationKey "Email" -NotificationThreshold 0.8 -ContactEmail "<Email>"
