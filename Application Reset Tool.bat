@echo off
setlocal enabledelayedexpansion

:: Create a temporary file to store the list of installed applications
set "tempfile=%TEMP%\installed_apps.txt"

:: Use PowerShell to get the list of installed applications and save to a temp file
echo Fetching installed applications...
powershell -command "Get-WmiObject -Class Win32_Product | Select-Object -Property Name, Version | Out-File -FilePath '%tempfile%' -Encoding utf8"

:: Simple loading bar
set "bar=Loading"
for /L %%i in (1,1,10) do (
    set /p "=." <nul
    timeout /t 1 >nul
)
echo.

:: Display installed applications
echo Installed Applications:
set "index=0"
for /f "skip=1 tokens=*" %%i in (%tempfile%) do (
    if not "%%i"=="" (
        echo !index!: %%i
        set "apps[!index!]=%%i"
        set /a index+=1
    )
)

:: Get user selection
set /p "choice=Enter the number of the application you want to reset or delete: "

:: Process the user's choice
if !choice! geq 0 if !choice! lss !index! (
    set "selected_app=!apps[%choice%]!"
    echo Resetting or deleting "!selected_app!"...

    :: Attempt to uninstall using WMIC
    wmic product where "name='!selected_app!'" call uninstall /nointeractive

    echo Application reset or deletion complete.
) else (
    echo Invalid choice. Please run the script again and choose a valid number.
)

:: Clean up
del "%tempfile%"
echo Done.
pause
endlocal
