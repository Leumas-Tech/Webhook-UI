@echo off
setlocal

:: Prompt for GitHub repository name and commit message
set /p repoName="Enter the new GitHub repository name: "
set /p commitMessage="Enter the commit message: "

:: Prompt for .gitignore template (e.g., Node, Python, etc.)
set /p gitignoreTemplate="Enter the .gitignore template (e.g., Node, Python, etc.): "

:: Create the new GitHub repository
gh repo create %repoName% --public --confirm

:: Initialize a new git repository locally
git init

:: Add a .gitignore file based on the specified template
echo Creating .gitignore file...
curl https://raw.githubusercontent.com/github/gitignore/main/%gitignoreTemplate%.gitignore -o .gitignore

:: Add all files to the repository
git add .

:: Commit the changes
git commit -m "%commitMessage%"

:: Add the remote repository URL
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/%repoName%.git

:: Push the changes to the new repository
git push -u origin master

echo Repository created and changes pushed to the new repository.

:end
endlocal
pause
