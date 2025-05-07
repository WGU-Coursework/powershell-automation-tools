<#
.SYNOPSIS
    Restores the “Finance” OU and its users from CSV.

.DESCRIPTION
    - Checks for an OU named “Finance” and, if found, deletes it.
    - Creates a new “Finance” OU.
    - Imports users from financePersonnel.csv into that OU,
      accommodating either “First Name” or “FirstName” (and similarly for last name).
    - Exports the newly created users’ key properties to AdResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    $ouDN = "OU=Finance,DC=consultingfirm,DC=com"

    # 1) Check for existing OU
    if ( Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue ) {
        Write-Host "Finance OU exists. Deleting..."
        Remove-ADOrganizationalUnit -Identity $ouDN -Recursive -Confirm:$false
        Write-Host "Finance OU deleted."
    } else {
        Write-Host "Finance OU does not exist."
    }

    # 2) Create the Finance OU
    Write-Host "Creating Finance OU..."
    New-ADOrganizationalUnit -Name "Finance" -Path "DC=consultingfirm,DC=com"
    Write-Host "Finance OU created."

    # 3) Import users from CSV
    $csvPath = Join-Path $PSScriptRoot "financePersonnel.csv"
    if (-Not (Test-Path $csvPath)) {
        throw "Cannot find financePersonnel.csv at path: $csvPath"
    }

    $users = Import-Csv -Path $csvPath

    #–– DEBUG: list detected headers
    Write-Host "Detected CSV columns:`n$($users[0].PSObject.Properties.Name -join "`n")"

    foreach ($u in $users) {
        # handle either “First Name” or “FirstName”
        $given   = $u.'First Name'
        if (-not $given) { $given = $u.FirstName }

        $surname = $u.'Last Name'
        if (-not $surname) { $surname = $u.LastName }

        if (-not $given -or -not $surname) {
            Write-Warning "Skipping row with missing first/last name: $($u | ConvertTo-Json -Compress)"
            continue
        }

        $display = "$given $surname"
        # build a simple UPN, e.g. jSmith@consultingfirm.com
        $initial = $given.Substring(0,1)
        $upn     = "$initial$surname@consultingfirm.com"

        Write-Host "Creating AD user: $display..."
        New-ADUser `
            -Name               $display `
            -GivenName          $given `
            -Surname            $surname `
            -DisplayName        $display `
            -UserPrincipalName  $upn `
            -Path               $ouDN `
            -PostalCode         ($u.'Postal Code'   -or $u.PostalCode) `
            -OfficePhone        ($u.'Office Phone'  -or $u.OfficePhone) `
            -MobilePhone        ($u.'Mobile Phone'  -or $u.MobilePhone) `
            -AccountPassword    (ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force) `
            -Enabled            $true

        Write-Host "  -> Created $display"
    }

    # 4) Export results
    Write-Host "Exporting AD results to AdResults.txt..."
    Get-ADUser -Filter * -SearchBase $ouDN `
        -Properties DisplayName,PostalCode,OfficePhone,MobilePhone |
      Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone |
      Out-File -FilePath (Join-Path $PSScriptRoot "AdResults.txt") -Encoding UTF8

    Write-Host "All done."
}
catch {
    Write-Error "ERROR: $($_.Exception.Message)"
}
