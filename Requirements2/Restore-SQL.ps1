<#
.SYNOPSIS
    Restores ClientDB and imports contacts.

.DESCRIPTION
    - Drops any existing ClientDB.
    - Creates ClientDB.
    - Creates the Client_A_Contacts table.
    - Reads NewClientData.csv and INSERTs each row.
    - Exports the table contents to SqlResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module SqlServer -ErrorAction Stop

    $serverInstance = ".\SQLEXPRESS"
    $dbName         = "ClientDB"
    $csvPath        = Join-Path $PSScriptRoot "NewClientData.csv"

    # 1) Drop existing database if present
    $exists = Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
        -Query "SELECT COUNT(*) FROM sys.databases WHERE name = '$dbName';"
    if ($exists.Column1 -gt 0) {
        Write-Host "Database '$dbName' exists. Dropping..."
        Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
            -Query "DROP DATABASE [$dbName];"
        Write-Host "Database dropped."
    } else {
        Write-Host "Database '$dbName' does not exist."
    }

    # 2) Create new database
    Write-Host "Creating database '$dbName'..."
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
        -Query "CREATE DATABASE [$dbName];"
    Write-Host "Database created."

    # 3) Create table
    $createTable = @"
USE [$dbName];
CREATE TABLE dbo.Client_A_Contacts (
    ContactID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName     NVARCHAR(50),
    LastName      NVARCHAR(50),
    Email         NVARCHAR(100),
    Phone         NVARCHAR(20)
);
"@
    Write-Host "Creating table Client_A_Contacts..."
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database $dbName -Query $createTable
    Write-Host "Table created."

    # 4) Import CSV via INSERT statements
    if (-not (Test-Path $csvPath)) {
        throw "Cannot find NewClientData.csv at path: $csvPath"
    }

    Write-Host "Importing data from CSV..."
    $rows = Import-Csv -Path $csvPath
    foreach ($r in $rows) {
        # Escape single-quotes
        $fn    = ($r.FirstName -replace "'","''")
        $ln    = ($r.LastName  -replace "'","''")
        $email = ($r.Email     -replace "'","''")
        $phone = ($r.Phone     -replace "'","''")

        $insert = @"
USE [$dbName];
INSERT INTO dbo.Client_A_Contacts (FirstName, LastName, Email, Phone)
VALUES (N'$fn', N'$ln', N'$email', N'$phone');
"@

        Invoke-Sqlcmd -ServerInstance $serverInstance `
            -Database $dbName `
            -Query $insert `
            -ErrorAction Stop
    }
    Write-Host "Data imported."

    # 5) Export query results
    Write-Host "Exporting SqlResults.txt..."
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database $dbName `
        -Query "SELECT * FROM dbo.Client_A_Contacts;" |
      Out-File -FilePath (Join-Path $PSScriptRoot "SqlResults.txt") -Encoding UTF8

    Write-Host "All done."
}
catch {
    Write-Error "ERROR: $($_.Exception.Message)"
    exit 1
}
