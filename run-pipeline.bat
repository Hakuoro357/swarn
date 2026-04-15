@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Swarn Pipeline Runner
echo ============================================
echo.

REM Get script directory
set "SWARN_DIR=%~dp0"
set "SWARN_DIR=%SWARN_DIR:~0,-1%"

REM Check if setup was run
if not exist "%SWARN_DIR%\config\orchestrator-config.json" (
    echo ERROR: Config not found!
    echo Please run setup.bat first.
    pause
    exit /b 1
)

REM Check if game project is configured
for /f "tokens=*" %%a in ('powershell -Command "(Get-Content '%SWARN_DIR%\config\orchestrator-config.json' | ConvertFrom-Json).project_paths.game_project"') do set "GAME_PROJECT=%%a"

if "%GAME_PROJECT%"=="../game" (
    echo WARNING: Game project not configured!
    echo Please run setup.bat first or edit orchestrator-config.json
    echo.
    set /p CONTINUE="Continue anyway? (y/n): "
    if /i not "!CONTINUE!"=="y" exit /b 1
)

echo Swarn path:  %SWARN_DIR%
echo Game project: %GAME_PROJECT%
echo.

REM Set environment variables
set "SWARN_HOME=%SWARN_DIR%"
set "PATH=%SWARN_DIR%;%PATH%"

REM Create logs directory
if not exist "%SWARN_DIR%\logs" mkdir "%SWARN_DIR%\logs"
if not exist "%SWARN_DIR%\logs\agents" mkdir "%SWARN_DIR%\logs\agents"

REM Start pipeline
echo ============================================
echo   Starting Pipeline
echo ============================================
echo.
echo [%date% %time%] Pipeline started >> "%SWARN_DIR%\logs\orchestrator.log"

REM ==================== STAGE 1: CONCEPT ====================
echo.
echo [Stage 1: Concept]
echo -------------------

echo [N1] Running market-analyst...
echo [%date% %time%] [N1] market-analyst started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run market-analyst -y
if errorlevel 1 (
    echo [N1] FAILED!
    echo [%date% %time%] [N1] market-analyst FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N1] market-analyst - SUCCESS
echo [%date% %time%] [N1] market-analyst SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N11] Running niche-analyst...
echo [%date% %time%] [N11] niche-analyst started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run niche-analyst -y
if errorlevel 1 (
    echo [N11] FAILED!
    echo [%date% %time%] [N11] niche-analyst FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N11] niche-analyst - SUCCESS
echo [%date% %time%] [N11] niche-analyst SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N2] Running game-concept-designer...
echo [%date% %time%] [N2] game-concept-designer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run game-concept-designer -y
if errorlevel 1 (
    echo [N2] FAILED!
    echo [%date% %time%] [N2] game-concept-designer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N2] game-concept-designer - SUCCESS
echo [%date% %time%] [N2] game-concept-designer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo.
echo [Stage 1] COMPLETE!
echo.

REM ==================== STAGE 2: ARCHITECTURE ====================
echo [Stage 2: Architecture]
echo ------------------------

echo [N3] Running game-architect...
echo [%date% %time%] [N3] game-architect started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run game-architect -y
if errorlevel 1 (
    echo [N3] FAILED!
    echo [%date% %time%] [N3] game-architect FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N3] game-architect - SUCCESS
echo [%date% %time%] [N3] game-architect SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N15] Running senior-typescript-game-developer...
echo [%date% %time%] [N15] senior-typescript-game-developer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run senior-typescript-game-developer -y
if errorlevel 1 (
    echo [N15] FAILED!
    echo [%date% %time%] [N15] senior-typescript-game-developer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N15] senior-typescript-game-developer - SUCCESS
echo [%date% %time%] [N15] senior-typescript-game-developer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo.
echo [Stage 2] COMPLETE!
echo.

REM ==================== STAGE 3: PARALLEL DEVELOPMENT ====================
echo [Stage 3: Parallel Development]
echo --------------------------------

echo [N4] Running game-developer...
echo [%date% %time%] [N4] game-developer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run game-developer -y
if errorlevel 1 (
    echo [N4] FAILED!
    echo [%date% %time%] [N4] game-developer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N4] game-developer - SUCCESS
echo [%date% %time%] [N4] game-developer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N5] Running ui-ux-designer...
echo [%date% %time%] [N5] ui-ux-designer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run ui-ux-designer -y
if errorlevel 1 (
    echo [N5] FAILED!
    echo [%date% %time%] [N5] ui-ux-designer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N5] ui-ux-designer - SUCCESS
echo [%date% %time%] [N5] ui-ux-designer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N6] Running level-designer...
echo [%date% %time%] [N6] level-designer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run level-designer -y
if errorlevel 1 (
    echo [N6] FAILED!
    echo [%date% %time%] [N6] level-designer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N6] level-designer - SUCCESS
echo [%date% %time%] [N6] level-designer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N7] Running audio-engineer...
echo [%date% %time%] [N7] audio-engineer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run audio-engineer -y
if errorlevel 1 (
    echo [N7] FAILED!
    echo [%date% %time%] [N7] audio-engineer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N7] audio-engineer - SUCCESS
echo [%date% %time%] [N7] audio-engineer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N8] Running asset-manager...
echo [%date% %time%] [N8] asset-manager started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run asset-manager -y
if errorlevel 1 (
    echo [N8] FAILED!
    echo [%date% %time%] [N8] asset-manager FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N8] asset-manager - SUCCESS
echo [%date% %time%] [N8] asset-manager SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N13] Running phaser-code-reviewer...
echo [%date% %time%] [N13] phaser-code-reviewer started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run phaser-code-reviewer -y
if errorlevel 1 (
    echo [N13] FAILED!
    echo [%date% %time%] [N13] phaser-code-reviewer FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N13] phaser-code-reviewer - SUCCESS
echo [%date% %time%] [N13] phaser-code-reviewer SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N17] Running documentation...
echo [%date% %time%] [N17] documentation started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run documentation -y
if errorlevel 1 (
    echo [N17] FAILED!
    echo [%date% %time%] [N17] documentation FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N17] documentation - SUCCESS
echo [%date% %time%] [N17] documentation SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo.
echo [Stage 3] COMPLETE!
echo.

REM ==================== STAGE 4: QUALITY ====================
echo [Stage 4: Quality]
echo -------------------

echo [N9] Running qa-tester...
echo [%date% %time%] [N9] qa-tester started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run qa-tester -y
if errorlevel 1 (
    echo [N9] FAILED!
    echo [%date% %time%] [N9] qa-tester FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N9] qa-tester - SUCCESS
echo [%date% %time%] [N9] qa-tester SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N10] Running performance-profiler...
echo [%date% %time%] [N10] performance-profiler started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run performance-profiler -y
if errorlevel 1 (
    echo [N10] FAILED!
    echo [%date% %time%] [N10] performance-profiler FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N10] performance-profiler - SUCCESS
echo [%date% %time%] [N10] performance-profiler SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N14] Running phaser-performance-profiler...
echo [%date% %time%] [N14] phaser-performance-profiler started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run phaser-performance-profiler -y
if errorlevel 1 (
    echo [N14] FAILED!
    echo [%date% %time%] [N14] phaser-performance-profiler FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N14] phaser-performance-profiler - SUCCESS
echo [%date% %time%] [N14] phaser-performance-profiler SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N18] Running localization...
echo [%date% %time%] [N18] localization started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run localization -y
if errorlevel 1 (
    echo [N18] FAILED!
    echo [%date% %time%] [N18] localization FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N18] localization - SUCCESS
echo [%date% %time%] [N18] localization SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo.
echo [Stage 4] COMPLETE!
echo.

REM ==================== STAGE 5: RELEASE ====================
echo [Stage 5: Release]
echo -------------------

echo [N16] Running git-devops...
echo [%date% %time%] [N16] git-devops started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run git-devops -y
if errorlevel 1 (
    echo [N16] FAILED!
    echo [%date% %time%] [N16] git-devops FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N16] git-devops - SUCCESS
echo [%date% %time%] [N16] git-devops SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo [N19] Running marketing-launch...
echo [%date% %time%] [N19] marketing-launch started >> "%SWARN_DIR%\logs\orchestrator.log"
qwen agent run marketing-launch -y
if errorlevel 1 (
    echo [N19] FAILED!
    echo [%date% %time%] [N19] marketing-launch FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
    goto :error
)
echo [N19] marketing-launch - SUCCESS
echo [%date% %time%] [N19] marketing-launch SUCCESS >> "%SWARN_DIR%\logs\orchestrator.log"

echo.
echo [Stage 5] COMPLETE!
echo.

REM ==================== SUCCESS ====================
echo ============================================
echo   PIPELINE COMPLETE!
echo ============================================
echo.
echo [%date% %time%] Pipeline COMPLETED SUCCESSFULLY >> "%SWARN_DIR%\logs\orchestrator.log"
echo.
echo Artifacts:
echo   %SWARN_DIR%\artifacts\
echo.
echo Game project:
echo   %GAME_PROJECT%\src\
echo.
pause
exit /b 0

:error
echo.
echo ============================================
echo   PIPELINE FAILED!
echo ============================================
echo.
echo [%date% %time%] Pipeline FAILED >> "%SWARN_DIR%\logs\orchestrator.log"
echo.
echo Check logs: %SWARN_DIR%\logs\orchestrator.log
echo.
pause
exit /b 1
