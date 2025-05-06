# Task 1: Scripting In Powershell

## Introduction

- In this task you will create PowerShell script.
- You will be expected to apply scripting standards and use exception and exit handling where appropriate.
- The completed product will prompt the user for input to complete various tasks until the user selects a prompt to exit the script.

## Scenario

- You are working as a server administrator at a consulting firm.
- Your client is a recent start-up company based out of Salt Lake City, Utah.
- They will be doubling their staff in the coming months, and you will need to start automating some processes that are commonly run.
- In the near future, they may be hiring an intern for the system administration.
- As such, you will need to comment throughout the script to identify the script processes.
- Please follow the task requirements below to help this company.

## Requirements

All supporting documentation, such as screenshots and proof of experience, should be collected in a pdf file and submitted separately from the main file. For more information, please see Computer System and Technology Requirements.  

- Create a PowerShell script named `prompts.ps1` within the `Requirements1` folder.
  - The first line of the script should be a comment which includes your first and last name along with your student ID.
  - The remainder of this task should be completed within the same script file, `prompts.ps1`.
- Create a “switch” statement that continues to prompt a user by doing each of the following activities, until a user presses key 5:
  - Prompt 1: User presses key 1
    - Using a regular expression...
      - List files within the `Requirements1` folder, with the `.log` file extension.
      - Redirect the results to a new file called `DailyLog.txt` within the same directory without overwriting existing data.
      - Each time the user selects this prompt, the current date should precede the listing.
  - Prompt 2: User presses key 2
    - List the files inside the `Requirements1` folder in tabular format, sorted in ascending alphabetical order.
    - Direct the output into a new file called `C916contents.txt` found in your `Requirements1` folder.
  - Prompt 3: User presses key 3
    - List the current CPU and memory usage.
  - Prompt 4: User presses key 4
    - List all the different running processes inside your system.
    - Sort the output by virtual size used least to greatest, and display it in grid format.
  - Prompt 5: User presses key 5
    - Exit the script execution.
- Apply scripting standards throughout your script, including the addition of comments that describe the behavior of each of the propmts for the switch statement listed above.
- Apply exception handling using `try-catch` for `System.OutOfMemoryException`.
- Run your script and take a screenshot of the user results when each prompt (3–4) is chosen.
  - Save each screenshot within the `Requirements1` folder.
- Compress all files (original and new) within the folder to a ZIP archive.
- When you are ready to submit your final script, run the `Get-FileHash` cmdlet against the `Requirements1` ZIP archive.
  - Note that hash value and place it into the comment section when you submit your task.

## Rubric

- The PowerShell script is created within the “Requirements1” folder, it is named correctly, and student name and ID are accurately included as a comment on the first line.
- Student uses switch statement and executes correctly.
- The scripting solution includes an expression that only extracts .log files and redirects to a new file without overwriting existing data.
- The scripting solution lists the files in the “Requirements” folder in tabular format and in ascending alphabetical order and the output is directed into a new file.
- The scripting solution lists both the current CPU and memory usage.
- The script logic accurately lists all running processes inside the system without listing any stopped processes. The list is in grid format and properly sorted.
- The script logic to exit the script execution is accurate.
- The script accurately applies scripting standards throughout the script, including added comments that describe the behavior of each part.
- The script accurately applies exception handling using try-catch for System.OutOfMemoryException.
- Accurate screenshots are provided for each action in parts B3–B4 in the correct folder and files within the folder are compressed to a ZIP archive.
- A completed file hash has been run, and the hash value is included in the comment section.


### File Restrictions

- File name may contain only letters, numbers, spaces, and these symbols: ! - _ . * ' ( )
- File size limit: 200 MB
- File types allowed:
  - doc, docx, rtf, xls, xlsx, ppt, pptx, odt, pdf, csv, txt, qt, mov, mpg, avi, mp3, wav, mp4, wma, flv, asf, mpeg, wmv, m4v, svg, tif, tiff, jpeg, jpg, gif, png, zip, rar, tar, 7z

# Task 1: Scripting In Powershell

## Introduction

- In this task, you will create two PowerShell scripts.
- You will be expected to manage an Active Directory and SQL Server within the PowerShell environment.
  - This management will include the configuration and administration of the servers.

## Scenario

- You have been hired as a consultant at a company.
- The company previously had an SQL server and Active Directory server configured throughout two separate Windows 2012 servers.
- However, all the drives (including backups) were destroyed due to unforeseen circumstances, and you need to write PowerShell scripts that can accomplish all the required tasks from the local server.

## Requirements

- Create a PowerShell script named `Restore-AD.ps1` within the attached `Requirements2` folder.
- Create a comment block and include your first and last name along with your student ID.
- Write the PowerShell commands in `Restore-AD.ps1` that perform all the following functions without user interaction:
  - Check for the existence of an Active Directory Organizational Unit (OU) named “Finance.” Output a message to the console that indicates if the OU exists or if it does not. If it already exists, delete it and output a message to the console that it was deleted.
  - Create an OU named “Finance.” Output a message to the console that it was created.
  - Import the `financePersonnel.csv` file (found in the attached `Requirements2` directory) into your Active Directory domain and directly into the finance OU. Be sure to include the following properties:
    - First Name
    - Last Name
    - Display Name (First Name + Last Name, including a space between)
    - Postal Code
    - Office Phone
    - Mobile Phone
- Include this line at the end of your script to generate an output file for submission:
  - `Get-ADUser -Filter * -SearchBase “ou=Finance,dc=consultingfirm,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt`
- Create a PowerShell script named `Restore-SQL.ps1` within the attached `Requirements2` folder.
- Create a comment block and include your first and last name along with your student ID.
- Write the PowerShell commands in a script named `Restore-SQL.ps1` that perform the following functions without user interaction:
  - Check for the existence of a database named `ClientDB`.
    - Output a message to the console that indicates if the database exists or if it does not.
    - If it already exists, delete it and output a message to the console that it was deleted.
  - Create a new database named `ClientDB` on the Microsoft SQL server instance.
    - Output a message to the console that the database was created.
  - Create a new table and name it `Client_A_Contacts` in your new database.
    - Output a message to the console that the table was created.
  - Insert the data (all rows and columns) from the `NewClientData.csv` file (found in the attached `Requirements2` folder) into the `Client_A_Contacts` table created above.
- Include this line at the end of your script to generate the output file SqlResults.txt for submission:
  - `Invoke-Sqlcmd -Database ClientDB –ServerInstance .\SQLEXPRESS -Query ‘SELECT * FROM dbo.Client_A_Contacts’ > .\SqlResults.txt`
- Apply exception handling using try-catch. Output any error messages to the console.
- Run your `Restore-AD.ps1` script from this console and take a screenshot of the output.
- Run your `Restore-SQL.ps1` script from this console and take a screenshot of the output.
- Compress the `Requirements2` folder as a ZIP archive.
  - When you are ready to submit your final task, run the `Get-FileHash` cmdlet against the `Requirements2` ZIP archive.
    - Note the hash value and place it into the comment section when you submit your task.
- Include all the following files intact within the `Requirements2` folder, including the original files and any additional files you created to support your script:
  - `Restore-AD.ps1`
  - `Restore-SQL.ps1`
  - `AdResults.txt`
  - `SqlResults.txt`
  - Screenshots
- Apply scripting standards throughout your script, including the addition of comments that describe the behavior of the script.


## File Restrictions

- File name may contain only letters, numbers, spaces, and these symbols: ! - _ . * ' ( )
- File size limit: 200 MB
- File types allowed:
  - doc, docx, rtf, xls, xlsx, ppt, pptx, odt, pdf, csv, txt, qt, mov, mpg, avi, mp3, wav, mp4, wma, flv, asf, mpeg, wmv, m4v, svg, tif, tiff, jpeg, jpg, gif, png, zip, rar, tar, 7z

## Rubric

- The PowerShell script is created within the “Requirements2” folder and includes a comment block that includes the first and last name and student ID number.
- The script checks for the existence of an Active Directory Organizational Unit (OU) named “Finance” and outputs a message of its existence. If the OU exists, the script deletes the OU and confirms the deletion with an output message.
- The script successfully creates an OU named “Finance” and a message is output to the console that it was created.
- The script imports the correct file including all rows and attributes into the correct OU.
- The ADResults.txt file includes all of the rows and attributes in the OU.
- The PowerShell script is created within the “Requirements2” folder and includes a comment block that includes the first and last name and student ID number.
- The script checks for the existence of a database named ClientDB and outputs a message of its existence. If the database exists, the script deletes the database and confirms the deletion with an output message.
- The script logic correctly creates a new database on the SQL server named “ClientDB.”
- The script logic correctly creates a new table named “Client_A_Contacts” and the table is added to the new database.
- The script logic inserts all the correct data from the “NewClientData.csv” file into the "Client_A_Contacts" SQL database.
- The SqlResults.txt file includes all the rows and attributes in the database table. The cmdlets is run correctly.
- The exception handling covers the appropriate part of the script and the error message with relevant details of the exception is provided.
- Accurate screenshots are provided for each action in the script.
- Accurate screenshots are provided for each action in the script.
- A hash value is provided and evidences integrity of the zipped file.
- All files are included within the “Requirements2” folder.
- The script accurately applies scripting standards throughout the script, including added comments that describe the behavior of the script.
