@echo off
setlocal

echo ============================================
echo   Swarn Pipeline Runner
echo ============================================
echo.

set "SWARN_DIR=%~dp0"
set "SWARN_DIR=%SWARN_DIR:~0,-1%"

REM Check config
if not exist "%SWARN_DIR%\config\orchestrator-config.json" (
    echo ERROR: Config not found!
    echo Run setup.bat first.
    pause
    exit /b 1
)

REM Run Python script
python "%SWARN_DIR%\run-pipeline.py" %*

echo.
pause
