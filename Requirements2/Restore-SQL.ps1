<#
.SYNOPSIS
    Restores ClientDB and imports contacts.

.DESCRIPTION
    - Drops any existing ClientDB (kills connections).
    - Creates ClientDB.
    - Drops & creates dbo.Client_A_Contacts with columns matching:
        first_name, last_name, city, county, zip, officePhone, mobilePhone.
    - Reads NewClientData.csv and INSERTs each row.
    - Exports the entire table to SqlResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module SqlServer -ErrorAction Stop

    $si     = ".\SQLEXPRESS"
    $db     = "ClientDB"
    $csv    = Join-Path $PSScriptRoot "NewClientData.csv"

    # 1) Drop & recreate database
    $exists = Invoke-Sqlcmd -ServerInstance $si -Database master `
        -Query "SELECT COUNT(*) AS Cnt FROM sys.databases WHERE name = N'$db';"
    if ($exists.Cnt -gt 0) {
        Write-Host "Dropping existing database '$db' (forcing disconnects)..."
        $drop = @"
ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [$db];
"@
        Invoke-Sqlcmd -ServerInstance $si -Database master -Query $drop -ErrorAction Stop
    }
    Write-Host "Creating database '$db'..."
    Invoke-Sqlcmd -ServerInstance $si -Database master `
        -Query "CREATE DATABASE [$db];" -ErrorAction Stop

    # 2) Drop & create table with matching columns
    $tableDDL = @"
USE [$db];

IF OBJECT_ID('dbo.Client_A_Contacts','U') IS NOT NULL
    DROP TABLE dbo.Client_A_Contacts;

CREATE TABLE dbo.Client_A_Contacts (
    ContactID    INT IDENTITY(1,1) PRIMARY KEY,
    first_name   NVARCHAR(100),
    last_name    NVARCHAR(100),
    city         NVARCHAR(100),
    county       NVARCHAR(100),
    zip          NVARCHAR(20),
    officePhone  NVARCHAR(50),
    mobilePhone  NVARCHAR(50)
);
"@
    Write-Host "Creating table Client_A_Contacts..."
    Invoke-Sqlcmd -ServerInstance $si -Database $db -Query $tableDDL -ErrorAction Stop

    # 3) Import CSV rows
    if (-not (Test-Path $csv)) {
        throw "Cannot find NewClientData.csv at path: $csv"
    }
    Write-Host "Importing data from CSV..."
    $rows = Import-Csv -Path $csv
    foreach ($r in $rows) {
        # escape single-quotes
        $fn = ($r.first_name  -replace "'","''")
        $ln = ($r.last_name   -replace "'","''")
        $ci = ($r.city        -replace "'","''")
        $co = ($r.county      -replace "'","''")
        $zp = ($r.zip         -replace "'","''")
        $op = ($r.officePhone -replace "'","''")
        $mp = ($r.mobilePhone -replace "'","''")

        $ins = @"
USE [$db];
INSERT INTO dbo.Client_A_Contacts
  (first_name, last_name, city, county, zip, officePhone, mobilePhone)
VALUES
  (N'$fn', N'$ln', N'$ci', N'$co', N'$zp', N'$op', N'$mp');
"@
        Invoke-Sqlcmd -ServerInstance $si -Database $db `
            -Query $ins -ErrorAction Stop
    }

    # 4) Export everything to SqlResults.txt
    Write-Host "Exporting SqlResults.txt..."
    Invoke-Sqlcmd -ServerInstance $si -Database $db `
        -Query "SELECT * FROM dbo.Client_A_Contacts ORDER BY ContactID;" |
      Out-File -FilePath (Join-Path $PSScriptRoot "SqlResults.txt") -Encoding UTF8

    Write-Host "All done."
}
catch {
    Write-Error "ERROR: $($_.Exception.Message)"
    exit 1
}
