
# Connect to Azure account
Connect-AzAccount

# =============================
# 1. Create a Management Group
# =============================
New-AzManagementGroup -GroupId "M365ManagementGroup" -DisplayName "M365 Management Group"

# =============================
# 2. Create Resource Groups
# =============================
New-AzResourceGroup -Name "RG-Production" -Location "WestUS"
New-AzResourceGroup -Name "RG-DevTest" -Location "WestUS"

# =============================
# 3. Configure Azure AD Roles and Enable MFA
# =============================
# Note: MFA enforcement is done via Conditional Access policies in Azure AD portal.
# Assign a role to a user example:
# Get-AzRoleDefinition | Where-Object {$_.RoleName -eq "Contributor"}
# New-AzRoleAssignment -ObjectId <UserObjectId> -RoleDefinitionName "Contributor" -Scope "/subscriptions/<SubscriptionId>"

# =============================
# 4. Apply Basic Azure Policies
# =============================
# Create a policy definition for allowed locations
$policyDefinition = New-AzPolicyDefinition -Name "AllowedLocations" -DisplayName "Allowed Locations" -PolicyType BuiltIn -PolicyRule '{"if":{"field":"location","notIn":["eastus","westus"]},"then":{"effect":"deny"}}'
New-AzPolicyAssignment -Name "AllowedLocationsAssignment" -Scope "/subscriptions/<SubscriptionId>" -PolicyDefinition $policyDefinition

# =============================
# 5. Enable Security Center
# =============================
Set-AzSecurityCenterSubscription -SubscriptionId <SubscriptionId> -Enable

# =============================
# 6. Set Up Cost Management Budgets
# =============================

New-AzConsumptionBudget -Name "MonthlyBudget" -Amount 100 -TimeGrain Monthly -StartDate (Get-Date) -EndDate (Get-Date).AddYears(1) -Category Cost -NotificationKey "Email" -NotificationThreshold 0.8 -ContactEmail "intunem3652026@outlook.com

# =============================
# 7. Create a Virtual Network
# =============================
New-AzVirtualNetwork -Name "VNet-Production" -ResourceGroupName "RG-Production" -Location "EastUS" -AddressPrefix "10.0.0.0/16" -Subnet @(@{Name="Subnet1";AddressPrefix="10.0.1.0/24"})
