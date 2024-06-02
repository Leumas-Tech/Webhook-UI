@echo off
setlocal enabledelayedexpansion

:: Path to webhooks.json
set WEBHOOKS_PATH=C:\Users\Willi\OneDrive\Desktop\Webhook Creator\nodejs-webhook-creator\webhooks.json

:: Read and parse webhooks.json
set WEBHOOKS_CONTENT=
for /f "tokens=* delims=" %%a in ('type "%WEBHOOKS_PATH%"') do (
    set "WEBHOOKS_CONTENT=!WEBHOOKS_CONTENT!%%a"
)

:: Function to parse JSON and enumerate webhooks
set /a count=0
set OPTIONS=
for /f "delims=" %%a in ('powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes('%WEBHOOKS_PATH%')) | ConvertFrom-Json | ForEach-Object { $_.name + '|' + $_.path + '|' + $_.handler }"') do (
    set /a count+=1
    set "OPTIONS=!OPTIONS!%%a|"
)

:: Display available webhooks
echo Available Webhooks:
set "options=!OPTIONS!"
for /l %%i in (1,1,%count%) do (
    for /f "tokens=1,2 delims=|" %%a in ("!options!") do (
        if "%%a" neq "" (
            echo %%i. %%a
        )
        set "options=!options:*|=!"
    )
)

:: Prompt user to choose a webhook
set /p choice=Choose a webhook to send (1-%count%):
if %choice% lss 1 if %choice% gtr %count% (
    echo Invalid choice.
    exit /b 1
)

:: Extract the chosen webhook details
set "chosen_name="
set "chosen_path="
set "chosen_handler="
set "options=!OPTIONS!"
for /l %%i in (1,1,%choice%) do (
    for /f "tokens=1,2,3 delims=|" %%a in ("!options!") do (
        if %%i equ %choice% (
            set "chosen_name=%%a"
            set "chosen_path=%%b"
            set "chosen_handler=%%c"
        )
        set "options=!options:*|=!"
    )
)

:: Display chosen webhook
echo Chosen Webhook:
echo Name: !chosen_name!
echo Path: !chosen_path!
echo Handler: !chosen_handler!

:: Prompt user for custom data or predefined data
set /p custom_data=Enter custom data in JSON format (or press Enter to use predefined data):

:: Send the webhook
if defined custom_data (
    echo Sending custom data...
    powershell -Command "Invoke-RestMethod -Uri http://localhost:3000!chosen_path! -Method Post -Body '%custom_data%' -ContentType 'application/json'"
) else (
    echo Sending predefined data...
    set predefined_data={"key":"value"}
    powershell -Command "Invoke-RestMethod -Uri http://localhost:3000!chosen_path! -Method Post -Body '%predefined_data%' -ContentType 'application/json'"
)

echo Webhook sent.
pause
