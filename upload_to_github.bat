@echo off
echo ==============================================
echo Uploading SD App to GitHub
echo Repository: https://github.com/TanyaGerdi/sd_app.git
echo ==============================================
echo.

:: Stage all current changes
echo Staging changes...
git add .

:: Commit the changes (if any)
echo.
echo Committing changes...
git commit -m "Upload app to new repository"

:: Push to the main branch on the new remote
echo.
echo Pushing to GitHub (main branch)...
git push -u origin main

echo.
echo ==============================================
echo Process completed!
echo ==============================================
pause
