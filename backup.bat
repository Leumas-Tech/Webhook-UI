@echo off
setlocal

:: Hardcoded path to the folder you want to backup
set "folderPath=C:\Users\Willi\OneDrive\Desktop\Webhook Creator"

:: Check if the folder exists
if not exist "%folderPath%" (
    echo The specified folder does not exist.
    goto :end
)

:: Set the backup folder name and location
set "backupFolderName=Webhook_Creator_Backup"
set "backupFolderPath=%folderPath%\..\%backupFolderName%"

:: Create the backup folder
if not exist "%backupFolderPath%" (
    mkdir "%backupFolderPath%"
)

:: Exclude the node_modules directory and create the backup
echo Creating backup of "%folderPath%" excluding "node_modules"...
robocopy "%folderPath%" "%backupFolderPath%" /E /XD node_modules

:: Check if the backup was created successfully
if exist "%backupFolderPath%" (
    echo Backup created successfully at "%backupFolderPath%".
) else (
    echo Failed to create backup.
)

:end
endlocal
pause
