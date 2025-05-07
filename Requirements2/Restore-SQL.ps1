<#
.SYNOPSIS
    Restores ClientDB and imports contacts.

.DESCRIPTION
    - Checks for and drops an existing ClientDB database.
    - Creates ClientDB.
    - Creates the Client_A_Contacts table.
    - Bulk-imports data from NewClientData.csv.
    - Exports the table contents to SqlResults.txt.

AUTHOR
    YourFirstName YourLastName
STUDENT ID
    123456789
#>

try {
    Import-Module SqlServer

    $serverInstance = ".\SQLEXPRESS"
    $dbName         = "ClientDB"
    $csvPath        = Join-Path $PSScriptRoot "NewClientData.csv"

    # 1) Check for existing database
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

    # 4) Import CSV data
    if (-Not (Test-Path $csvPath)) { throw "Cannot find NewClientData.csv at $csvPath" }
    Write-Host "Importing data from CSV..."
    $bulkInsert = @"
BULK INSERT dbo.Client_A_Contacts
FROM '$csvPath'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001'
);
"@
    Invoke-Sqlcmd -ServerInstance $serverInstance -Database $dbName -Query $bulkInsert
    Write-Host "Data imported."

    # 5) Export query results
    Write-Host "Exporting SqlResults.txt..."
    Invoke-Sqlcmd -Database $dbName -ServerInstance $serverInstance `
        -Query "SELECT * FROM dbo.Client_A_Contacts;" |
      Out-File -FilePath (Join-Path $PSScriptRoot "SqlResults.txt") -Encoding UTF8
    Write-Host "Done."
}
catch {
    Write-Error "ERROR: $($_.Exception.Message)"
}
