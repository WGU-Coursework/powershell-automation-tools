<#
.SYNOPSIS
    Restores the “Finance” OU and its users from CSV.

.DESCRIPTION
    - Attempts to delete any existing Finance OU (continues if Access-Denied).
    - Creates a new Finance OU only if it doesn’t already exist.
    - Imports users from financePersonnel.csv into that OU,
      supporting both “First Name”/“FirstName” and “Last Name”/“LastName” headers.
    - Exports the created users’ key properties to AdResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    $ouDN    = "OU=Finance,DC=consultingfirm,DC=com"
    $csvPath = Join-Path $PSScriptRoot "financePersonnel.csv"

    #
    # 1) Attempt to delete the existing OU (warn and continue on failure)
    #
    if ( Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue ) {
        Write-Host "Finance OU exists. Attempting to delete..."
        try {
            Remove-ADOrganizationalUnit `
              -Identity $ouDN `
              -Recursive `
              -Confirm:$false `
              -ErrorAction Stop
            Write-Host "  -> Finance OU deleted."
        }
        catch {
            Write-Warning "  -> Could not delete Finance OU: $($_.Exception.Message)`n     (continuing with existing OU)"
        }
    }
    else {
        Write-Host "Finance OU does not exist."
    }

    #
    # 2) Create the Finance OU only if it's absent
    #
    if (-not ( Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue )) {
        Write-Host "Creating Finance OU..."
        New-ADOrganizationalUnit `
          -Name "Finance" `
          -Path "DC=consultingfirm,DC=com" `
          -ErrorAction Stop
        Write-Host "  -> Finance OU created."
    }
    else {
        Write-Host "Finance OU already exists; skipping creation."
    }

    #
    # 3) Import users from CSV
    #
    if (-not (Test-Path $csvPath)) {
        throw "Cannot find financePersonnel.csv at path: $csvPath"
    }

    $users = Import-Csv -Path $csvPath

    #–– DEBUG: show detected headers
    Write-Host "Detected CSV columns:`n$($users[0].PSObject.Properties.Name -join "`n")"

    foreach ($u in $users) {
        # support spaced vs un-spaced header names
        $given   = $u.'First Name';    if (-not $given)   { $given   = $u.FirstName }
        $surname = $u.'Last Name';     if (-not $surname) { $surname = $u.LastName  }

        if (-not $given -or -not $surname) {
            Write-Warning "Skipping row missing name: $($u | ConvertTo-Json -Compress)"
            continue
        }

        $display = "$given $surname"
        $upn     = ($given.Substring(0,1) + $surname) + "@consultingfirm.com"

        Write-Host "Creating AD user: $display..."
        New-ADUser `
          -Name              $display `
          -GivenName         $given `
          -Surname           $surname `
          -DisplayName       $display `
          -UserPrincipalName $upn `
          -Path              $ouDN `
          -PostalCode        ($u.'Postal Code'  -or $u.PostalCode) `
          -OfficePhone       ($u.'Office Phone' -or $u.OfficePhone) `
          -MobilePhone       ($u.'Mobile Phone' -or $u.MobilePhone) `
          -AccountPassword   (ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force) `
          -Enabled           $true `
          -ErrorAction Stop

        Write-Host "  -> Created $display"
    }

    #
    # 4) Export results
    #
    Write-Host "Exporting AD results to AdResults.txt..."
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
