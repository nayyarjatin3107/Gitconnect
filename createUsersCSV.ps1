
# Define password profile
$PasswordProfile = @{
    Password = 'TempP@ssword123'
    ForceChangePasswordNextSignIn = $true
}

# Import users from CSV
$Users = Import-Csv -Path "D:\Scripts\Users.csv"

# Loop through each user and create account
foreach ($User in $Users) {
    try {
        New-MgUser `
            -DisplayName $User.DisplayName `
            -PasswordProfile $PasswordProfile `
            -UserPrincipalName $User.UserPrincipalName `
            -MailNickName $User.MailNickName `
            -AccountEnabled:$true `
            -UsageLocation $User.UsageLocation

        Write-Host "User created: $($User.DisplayName)"
    }
    catch {
        Write-Host "Failed to create user: $($User.DisplayName) - $_"
    }
}
