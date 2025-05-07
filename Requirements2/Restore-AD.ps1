<#
.SYNOPSIS
    Restores the “Finance” OU and its users from CSV.

.DESCRIPTION
    - Deletes any existing Finance OU (using supplied creds).
    - Creates a new Finance OU (using supplied creds).
    - Imports users from financePersonnel.csv into that OU,
      supporting both “First Name” and “FirstName” headers.
    - Exports the created users to AdResults.txt.

.PARAMETER Credential
    A PSCredential for an account in the Domain Admins group.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][PSCredential]
    $Credential
)

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    $ouDN    = "OU=Finance,DC=consultingfirm,DC=com"
    $csvPath = Join-Path $PSScriptRoot "financePersonnel.csv"

    # 1) Delete existing OU if present
    $existing = Get-ADOrganizationalUnit `
        -Filter "DistinguishedName -eq '$ouDN'" `
        -Credential $Credential `
        -ErrorAction SilentlyContinue

    if ($existing) {
        Write-Host "Finance OU exists. Deleting…"
        Remove-ADOrganizationalUnit `
            -Identity $ouDN `
            -Recursive `
            -Confirm:$false `
            -Credential $Credential `
            -ErrorAction Stop
        Write-Host "Finance OU deleted."
    }
    else {
        Write-Host "Finance OU does not exist."
    }

    # 2) Create the Finance OU
    Write-Host "Creating Finance OU..."
    New-ADOrganizationalUnit `
        -Name "Finance" `
        -Path "DC=consultingfirm,DC=com" `
        -Credential $Credential `
        -ErrorAction Stop
    Write-Host "Finance OU created."

    # 3) Import users from CSV
    if (-not (Test-Path $csvPath)) {
        throw "Cannot find financePersonnel.csv at: $csvPath"
    }
    $users = Import-Csv -Path $csvPath

    Write-Host "Detected CSV columns:`n$($users[0].PSObject.Properties.Name -join "`n")"

    foreach ($u in $users) {
        # support both spaced and un-spaced headers
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
            -Credential        $Credential `
            -ErrorAction Stop

        Write-Host "  -> Created $display"
    }

    # 4) Export results
    Write-Host "Exporting to AdResults.txt..."
    Get-ADUser `
        -Filter * `
        -SearchBase $ouDN `
        -Properties DisplayName,PostalCode,OfficePhone,MobilePhone `
        -Credential $Credential |
      Select-Object DisplayName,PostalCode,OfficePhone,MobilePhone |
      Out-File -FilePath (Join-Path $PSScriptRoot "AdResults.txt") -Encoding UTF8

    Write-Host "All done."
}
catch {
    Write-Error "FATAL: $($_.Exception.Message)"
    exit 1
}
