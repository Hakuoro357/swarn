@echo off
setlocal

echo ============================================
echo   Swarn Setup
echo ============================================
echo.

REM Get script directory
set "SWARN_DIR=%~dp0"
set "SWARN_DIR=%SWARN_DIR:~0,-1%"

REM Ask for game project path
set /p GAME_PATH="Enter path to your game project (e.g. C:\pro\my-game): "

if "%GAME_PATH%"=="" (
    echo Error: Path cannot be empty
    pause
    exit /b 1
)

echo.
echo Swarn path: %SWARN_DIR%
echo Game path:  %GAME_PATH%
echo.

REM Run PowerShell script with bypass execution policy
powershell -ExecutionPolicy Bypass -File "%SWARN_DIR%\setup.ps1" -GamePath "%GAME_PATH%" -SwarnPath "%SWARN_DIR%"

echo.
pause
