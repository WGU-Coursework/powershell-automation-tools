<#
.SYNOPSIS
    Restores the “Finance” OU and its users from CSV.

.DESCRIPTION
    - Attempts to delete any existing Finance OU (warns and continues on failure).
    - Creates the Finance OU only if it’s absent.
    - Imports users from financePersonnel.csv into that OU, using these CSV columns:
        • First_Name
        • Last_Name
        • samAccount
        • PostalCode
        • OfficePhone
        • MobilePhone
    - Skips any row whose SamAccountName or UPN is already in AD.
    - Exports the created users’ DisplayName, PostalCode, OfficePhone, MobilePhone to AdResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    $ouDN    = "OU=Finance,DC=consultingfirm,DC=com"
    $csvPath = Join-Path $PSScriptRoot "financePersonnel.csv"

    # 1) Delete existing Finance OU (warn & continue on failure)
    if ( Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue ) {
        Write-Host "Finance OU exists. Attempting to delete..."
        try {
            Remove-ADOrganizationalUnit -Identity $ouDN -Recursive -Confirm:$false -ErrorAction Stop
            Write-Host "  -> Finance OU deleted."
        }
        catch {
            Write-Warning "  -> Could not delete Finance OU: $($_.Exception.Message) (continuing)"
        }
    }
    else {
        Write-Host "Finance OU does not exist."
    }

    # 2) Create the OU only if it’s still absent
    if (-not ( Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue )) {
        Write-Host "Creating Finance OU..."
        New-ADOrganizationalUnit -Name "Finance" -Path "DC=consultingfirm,DC=com" -ErrorAction Stop
        Write-Host "  -> Finance OU created."
    }
    else {
        Write-Host "Finance OU already exists; skipping creation."
    }

    # 3) Import users from CSV
    if (-not (Test-Path $csvPath)) {
        throw "Cannot find financePersonnel.csv at path: $csvPath"
    }
    $users = Import-Csv -Path $csvPath

    Write-Host "Detected CSV columns:`n$($users[0].PSObject.Properties.Name -join "`n")`n"

    foreach ($u in $users) {
        $given   = $u.First_Name
        $surname = $u.Last_Name

        if (-not $given -or -not $surname) {
            Write-Warning "Skipping row missing name: $($u | ConvertTo-Json -Compress)"
            continue
        }

        $display = "$given $surname"
        $sam     = $u.samAccount
        $upn     = "$sam@consultingfirm.com"

        # 3a) Skip if SamAccountName already exists
        if ( Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue ) {
            Write-Host "User '$sam' already exists; skipping."
            continue
        }

        # 3b) Skip if UPN already exists
        if ( Get-ADUser -Filter "UserPrincipalName -eq '$upn'" -ErrorAction SilentlyContinue ) {
            Write-Host "UPN '$upn' already exists; skipping."
            continue
        }

        Write-Host "Creating AD user: $display..."
        New-ADUser `
          -Name              $display `
          -GivenName         $given `
          -Surname           $surname `
          -DisplayName       $display `
          -SamAccountName    $sam `
          -UserPrincipalName $upn `
          -Path              $ouDN `
          -PostalCode        $u.PostalCode `
          -OfficePhone       $u.OfficePhone `
          -MobilePhone       $u.MobilePhone `
          -AccountPassword   (ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force) `
          -Enabled           $true `
          -ErrorAction Stop

        Write-Host "  -> Created $display"
    }

    # 4) Export results
    Write-Host "`nExporting AD results to AdResults.txt..."
    Get-ADUser `
      -Filter * `
      -SearchBase $ouDN `
      -Properties DisplayName,PostalCode,OfficePhone,MobilePhone |
      Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone |
      Out-File -FilePath (Join-Path $PSScriptRoot "AdResults.txt") -Encoding UTF8

    Write-Host "All done."
}
catch {
    Write-Error "FATAL ERROR: $($_.Exception.Message)"
    exit 1
}
