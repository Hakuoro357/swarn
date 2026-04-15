# Swarn Setup Script
# Usage: .\setup.ps1 -GamePath "C:\path\to\my-game"

param(
    [Parameter(Mandatory=$true)]
    [string]$GamePath,

    [string]$SwarnPath = (Split-Path -Parent $PSScriptRoot)
)

Write-Host "=== Swarn Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Swarn path: $SwarnPath" -ForegroundColor Gray
Write-Host "Game path:  $GamePath" -ForegroundColor Gray
Write-Host ""

# Check if game directory exists
if (-not (Test-Path $GamePath)) {
    Write-Host "Creating game project directory: $GamePath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $GamePath -Force | Out-Null
    
    # Create directory structure
    $dirs = @(
        "$GamePath\src\core",
        "$GamePath\src\scenes",
        "$GamePath\src\entities",
        "$GamePath\src\systems",
        "$GamePath\src\ui\components",
        "$GamePath\src\ui\screens",
        "$GamePath\public\sprites\characters",
        "$GamePath\public\sprites\items",
        "$GamePath\public\audio\sfx",
        "$GamePath\public\audio\music",
        "$GamePath\public\levels",
        "$GamePath\tests\unit",
        "$GamePath\docs"
    )
    
    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    Write-Host "Game project structure created" -ForegroundColor Green
} else {
    Write-Host "Game project directory already exists: $GamePath" -ForegroundColor Yellow
}

# Update Swarn configuration
$configPath = Join-Path $SwarnPath "config\orchestrator-config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    
    # Update paths
    $config.project_paths.swarn_home = $SwarnPath
    $config.project_paths.game_project = $GamePath
    $config.project_paths.game_src = "$GamePath\src"
    $config.project_paths.game_public = "$GamePath\public"
    $config.project_paths.game_config = "$GamePath\config"
    $config.project_paths.game_tests = "$GamePath\tests"
    
    # Save configuration
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    
    Write-Host "Swarn configuration updated" -ForegroundColor Green
    Write-Host "  Game project: $GamePath" -ForegroundColor Gray
} else {
    Write-Host "Swarn config not found: $configPath" -ForegroundColor Red
    exit 1
}

# Initialize npm in game project
$packageJson = "$GamePath\package.json"
if (-not (Test-Path $packageJson)) {
    Write-Host "Initializing npm in game project..." -ForegroundColor Yellow
    Set-Location $GamePath
    npm init -y | Out-Null
    
    # Install Phaser dependencies
    Write-Host "Installing Phaser dependencies..." -ForegroundColor Yellow
    npm install phaser | Out-Null
    npm install -D typescript vite @types/node | Out-Null
    
    Write-Host "npm initialized and dependencies installed" -ForegroundColor Green
} else {
    Write-Host "npm already initialized in game project" -ForegroundColor Yellow
}

# Set environment variables for current session
$env:SWARN_HOME = $SwarnPath
$env:GAME_PROJECT = $GamePath

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Review config: $SwarnPath\config\orchestrator-config.json" -ForegroundColor Gray
Write-Host "2. Run pipeline: qwen agent run orchestrator" -ForegroundColor Gray
Write-Host "3. Check results: $GamePath\src" -ForegroundColor Gray
Write-Host ""
Write-Host "Project structure:" -ForegroundColor White
Write-Host "  $GamePath\" -ForegroundColor Gray
Write-Host "  ├── src\           (game code)" -ForegroundColor Gray
Write-Host "  ├── public\        (assets)" -ForegroundColor Gray
Write-Host "  ├── tests\         (unit tests)" -ForegroundColor Gray
Write-Host "  └── docs\          (documentation)" -ForegroundColor Gray
Write-Host ""
Write-Host "Environment variables set:" -ForegroundColor White
Write-Host "  SWARN_HOME=$env:SWARN_HOME" -ForegroundColor Gray
Write-Host "  GAME_PROJECT=$env:GAME_PROJECT" -ForegroundColor Gray
Write-Host ""
