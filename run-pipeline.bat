@echo off
setlocal

echo ============================================
echo   Swarn Pipeline Runner
echo ============================================
echo.

set "SWARN_DIR=%~dp0"
set "SWARN_DIR=%SWARN_DIR:~0,-1%"

REM Add npm to PATH (qwen installed via npm)
set "PATH=%APPDATA%\npm;%PATH%"

REM Check config
if not exist "%SWARN_DIR%\config\orchestrator-config.json" (
    echo ERROR: Config not found!
    echo Run setup.bat first.
    pause
    exit /b 1
)

REM If arguments provided, pass them through
if not "%~1"=="" (
    python "%SWARN_DIR%\run-pipeline.py" %*
    echo.
    pause
    exit /b
)

REM Show menu
echo What do you want to do?
echo.
echo   1. Resume pipeline (skip completed agents) [RECOMMENDED]
echo   2. Run full pipeline from scratch
echo   3. Run Stage 1 only (Concept)
echo   4. Run Stage 2 only (Architecture)
echo   5. Run Stage 3 only (Development)
echo   6. Run Stage 4 only (Quality)
echo   7. Run Stage 5 only (Release)
echo.
set /p CHOICE="Enter choice (1-7): "

if "%CHOICE%"=="1" python "%SWARN_DIR%\run-pipeline.py" --resume
if "%CHOICE%"=="2" python "%SWARN_DIR%\run-pipeline.py"
if "%CHOICE%"=="3" python "%SWARN_DIR%\run-pipeline.py" --stage=1
if "%CHOICE%"=="4" python "%SWARN_DIR%\run-pipeline.py" --stage=2
if "%CHOICE%"=="5" python "%SWARN_DIR%\run-pipeline.py" --stage=3
if "%CHOICE%"=="6" python "%SWARN_DIR%\run-pipeline.py" --stage=4
if "%CHOICE%"=="7" python "%SWARN_DIR%\run-pipeline.py" --stage=5

echo.
pause
