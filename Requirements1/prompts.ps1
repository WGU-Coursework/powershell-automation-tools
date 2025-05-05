# Name: Anthony Russano, Student ID: 012551576

# Function to display the menu
function Show-Menu {
    Write-Host "===== System Administration Menu ====="
    Write-Host "1. List .log files and append to DailyLog.txt with date"
    Write-Host "2. List directory contents to C916contents.txt"
    Write-Host "3. Display CPU and memory usage"
    Write-Host "4. List running processes by virtual memory usage"
    Write-Host "5. Exit"
    Write-Host "====================================="
}

# Main script loop
do {
    try {
        # Clear screen and show menu
        Clear-Host
        Show-Menu

        # Prompt user for selection
        $choice = Read-Host "Enter your choice (1-5)"

        switch ($choice) {
            # Option 1: List .log files and append to DailyLog.txt
            1 {
                # Get current date for logging
                $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                # Get .log files in current directory using regex
                $logFiles = Get-ChildItem -Path . -File | Where-Object { $_.Name -match "\.log$" }
                
                # Append date and files to DailyLog.txt
                "$currentDate" | Out-File -FilePath ".\DailyLog.txt" -Append
                if ($logFiles) {
                    $logFiles | Select-Object Name, LastWriteTime, Length | Out-File -FilePath ".\DailyLog.txt" -Append
                } else {
                    "No .log files found" | Out-File -FilePath ".\DailyLog.txt" -Append
                }
                Write-Host "Log files appended to DailyLog.txt"
                Write-Host "Press any key to continue..."
                $null = Read-Host
            }

            # Option 2: List directory contents to C916contents.txt
            2 {
                # Get all files in current directory, sort alphabetically
                Get-ChildItem -Path . | Sort-Object Name | Format-Table Name, LastWriteTime, Length -AutoSize | Out-File -FilePath ".\C916contents.txt"
                Write-Host "Directory contents written to C916contents.txt"
                Write-Host "Press any key to continue..."
                $null = Read-Host
            }

            # Option 3: Display CPU and memory usage
            3 {
                # Get CPU usage
                $cpu = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | 
                       Where-Object { $_.Name -eq "_Total" } | 
                       Select-Object -ExpandProperty PercentProcessorTime
                # Get memory usage
                $memory = Get-CimInstance Win32_OperatingSystem
                $totalMemory = $memory.TotalVisibleMemorySize
                $freeMemory = $memory.FreePhysicalMemory
                $usedMemory = $totalMemory - $freeMemory
                $memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)

                Write-Host "CPU Usage: $cpu%"
                Write-Host "Memory Usage: $memoryPercent% ($usedMemory KB / $totalMemory KB)"
                Write-Host "Press any key to continue..."
                $null = Read-Host
            }

            # Option 4: List running processes sorted by virtual memory
            4 {
                # Get processes, sort by virtual memory size, display in grid
                Get-Process | Sort-Object VirtualMemorySize | 
                    Select-Object ProcessName, ID, VirtualMemorySize, WorkingSet | 
                    Out-GridView -Title "Running Processes (Sorted by Virtual Memory)"
                Write-Host "Press any key to continue..."
                $null = Read-Host
            }

            # Option 5: Exit
            5 {
                Write-Host "Exiting script..."
                exit
            }

            default {
                Write-Host "Invalid choice. Please select 1-5."
                Write-Host "Press any key to continue..."
                $null = Read-Host
            }
        }
    }
    catch [System.OutOfMemoryException] {
        # Handle out of memory exception
        Write-Host "Error: System ran out of memory. Please close some applications and try again."
        Write-Host "Press any key to continue..."
        $null = Read-Host
    }
    catch {
        # Handle any other unexpected errors
        Write-Host "An unexpected error occurred: $_"
        Write-Host "Press any key to continue..."
        $null = Read-Host
    }
} while ($true)