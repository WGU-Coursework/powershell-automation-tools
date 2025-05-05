# Task 1L Scripting In Powershell

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
    - Direct the output into a new file called `C916contents.txt` found in your “Requirements1” folder.
  - List the current CPU and memory usage. (User presses key 3.)
  - List all the different running processes inside your system. Sort the output by virtual size used least to greatest, and display it in grid format. (User presses key 4.)
  - Exit the script execution. (User presses key 5.)
- Apply scripting standards throughout your script, including the addition of comments that describe the behavior of each of the parts of the switch statement listed above.
- Apply exception handling using try-catch for System.OutOfMemoryException.
- Run your script and take a screenshot of the user results when each prompt (3–4) is chosen.
  - Save each screenshot within the `Requirements1` folder.
  - Compress all files (original and new) within the folder to a ZIP archive.
- When you are ready to submit your final script, run the Get-FileHash cmdlet against the `Requirements1` ZIP archive.
  - Note that hash value and place it into the comment section when you submit your task.

### File Restrictions

- File name may contain only letters, numbers, spaces, and these symbols: ! - _ . * ' ( )
- File size limit: 200 MB
- File types allowed:
  - doc, docx, rtf, xls, xlsx, ppt, pptx, odt, pdf, csv, txt, qt, mov, mpg, avi, mp3, wav, mp4, wma, flv, asf, mpeg, wmv, m4v, svg, tif, tiff, jpeg, jpg, gif, png, zip, rar, tar, 7z