@echo off
setlocal

:: Prompt for commit message
set /p commitMessage="Enter the commit message: "

:: Add all files to the repository
git add .

:: Commit the changes
git commit -m "%commitMessage%"

:: Push the changes to the existing repository
git push origin master

echo Changes pushed to the existing repository.

:end
endlocal
pause
