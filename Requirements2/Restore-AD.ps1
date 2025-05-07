<#
.SYNOPSIS
    Restores the “Finance” OU and its users from CSV.

.DESCRIPTION
    - Checks for an OU named “Finance” and, if found, deletes it.
    - Creates a new “Finance” OU.
    - Imports users from financePersonnel.csv into that OU.
    - Exports the newly created users’ key properties to AdResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module ActiveDirectory

    $ouDN = "OU=Finance,DC=consultingfirm,DC=com"
    # 1) Check if OU exists
    if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue) {
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
    if (-Not (Test-Path $csvPath)) { throw "Cannot find financePersonnel.csv at $csvPath" }

    $users = Import-Csv -Path $csvPath
    foreach ($u in $users) {
        $given  = $u.'First Name'
        $surname= $u.'Last Name'
        $display= "$given $surname"
        $upn    = ($given.Substring(0,1) + $surname) + "@consultingfirm.com"

        Write-Host "Creating AD user: $display..."
        New-ADUser `
            -GivenName      $given `
            -Surname        $surname `
            -DisplayName    $display `
            -UserPrincipalName $upn `
            -Name           $display `
            -PostalCode     $u.'Postal Code' `
            -OfficePhone    $u.'Office Phone' `
            -MobilePhone    $u.'Mobile Phone' `
            -Path           $ouDN `
            -AccountPassword (ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force) `
            -Enabled        $true

        Write-Host "Created $display."
    }

    # 4) Export results
    Write-Host "Exporting AD results to AdResults.txt..."
    Get-ADUser -Filter * -SearchBase $ouDN `
        -Properties DisplayName,PostalCode,OfficePhone,MobilePhone |
      Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone |
      Out-File -FilePath (Join-Path $PSScriptRoot "AdResults.txt") -Encoding UTF8

    Write-Host "Done."
}
catch {
    Write-Error "ERROR: $($_.Exception.Message)"
}
