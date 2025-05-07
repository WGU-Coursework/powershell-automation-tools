<#
.SYNOPSIS
    Restores ClientDB and imports contacts.

.DESCRIPTION
    - Drops any existing ClientDB, forcibly rolling back active connections.
    - Creates ClientDB.
    - Drops & re-creates the Client_A_Contacts table.
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

    # 1) Drop database if it exists (force single-user + rollback immediate)
    Write-Host "Checking for existing database '$dbName'..."
    $exists = Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
        -Query "SELECT COUNT(*) AS Cnt FROM sys.databases WHERE name = N'$dbName';"
    
    if ($exists.Cnt -gt 0) {
        Write-Host "Database '$dbName' exists. Dropping (killing connections)..."
        $dropDbSql = @"
ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [$dbName];
"@
        Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
            -Query $dropDbSql -ErrorAction Stop
        Write-Host "Database '$dbName' dropped."
    }
    else {
        Write-Host "Database '$dbName' does not exist."
    }

    # 2) Create new database
    Write-Host "Creating database '$dbName'..."
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database master `
        -Query "CREATE DATABASE [$dbName];" -ErrorAction Stop
    Write-Host "Database '$dbName' created."

    # 3) Drop & create table
    $createTableSql = @"
USE [$dbName];

IF OBJECT_ID('dbo.Client_A_Contacts','U') IS NOT NULL
    DROP TABLE dbo.Client_A_Contacts;

CREATE TABLE dbo.Client_A_Contacts (
    ContactID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName  NVARCHAR(50),
    Email     NVARCHAR(100),
    Phone     NVARCHAR(20)
);
"@
    Write-Host "Re-creating table Client_A_Contacts..."
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database $dbName `
        -Query $createTableSql -ErrorAction Stop
    Write-Host "Table Client_A_Contacts is ready."

    # 4) Insert CSV rows
    if (-not (Test-Path $csvPath)) {
        throw "Cannot find NewClientData.csv at path: $csvPath"
    }
    Write-Host "Importing data from CSV..."
    $rows = Import-Csv -Path $csvPath

    foreach ($r in $rows) {
        # Escape single-quotes in text fields
        $fn    = ($r.FirstName -replace "'","''")
        $ln    = ($r.LastName  -replace "'","''")
        $email = ($r.Email     -replace "'","''")
        $phone = ($r.Phone     -replace "'","''")

        $insertSql = @"
USE [$dbName];
INSERT INTO dbo.Client_A_Contacts (FirstName, LastName, Email, Phone)
VALUES (N'$fn', N'$ln', N'$email', N'$phone');
"@
        Invoke-Sqlcmd -ServerInstance $serverInstance -Database $dbName `
            -Query $insertSql -ErrorAction Stop
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
