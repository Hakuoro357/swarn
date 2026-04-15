#!/usr/bin/env python3
"""
Swarn Pipeline Runner
Usage: python run-pipeline.py [--stage N]
"""

import subprocess
import sys
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    RED = '\033[91m'
    GRAY = '\033[90m'
    RESET = '\033[0m'

def log(msg, color=Colors.RESET):
    print(f"{color}{msg}{Colors.RESET}")

def success(msg):
    log(f"  ✓ {msg}", Colors.GREEN)

def fail(msg):
    log(f"  ✗ {msg}", Colors.RED)

def info(msg):
    log(f"  {msg}", Colors.GRAY)

def stage_msg(msg):
    log(f"\n{msg}", Colors.CYAN)

# Paths
SWARN_DIR = Path(__file__).parent
CONFIG_PATH = SWARN_DIR / "config" / "orchestrator-config.json"
AGENTS_DIR = SWARN_DIR / ".qwen" / "agents"
LOGS_DIR = SWARN_DIR / "logs"
LOG_FILE = LOGS_DIR / "orchestrator.log"

def find_qwen():
    """Find qwen executable"""
    # Try shutil.which first
    qwen_path = shutil.which("qwen")
    if qwen_path:
        return qwen_path
    
    # Try common Windows locations
    appdata = os.environ.get("APPDATA", "")
    candidates = [
        Path(appdata) / "npm" / "qwen.cmd",
        Path(appdata) / "npm" / "qwen.exe",
        Path("C:/Program Files/nodejs/qwen.cmd"),
    ]
    
    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    
    return None

QWEN_CMD = find_qwen()

def load_config():
    with open(CONFIG_PATH, 'r', encoding='utf-8-sig') as f:
        return json.load(f)

def write_log(agent, status, duration):
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": datetime.now().isoformat(),
        "agent": agent,
        "status": status,
        "duration_seconds": duration
    }
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

AGENT_TIMEOUTS = {
    "N4-GameDev": 900,       # 15 min - generates lots of code
    "N15-SeniorTS": 900,     # 15 min - deep review
    "N2-ConceptDesigner": 600,  # 10 min - complex GDD
}
DEFAULT_TIMEOUT = 480  # 8 min

def check_agent_completed(agent_name):
    """Check if agent already completed"""
    # Method 1: Check log file for success entry
    if LOG_FILE.exists():
        try:
            content = LOG_FILE.read_text(encoding='utf-8-sig')
            for line in content.splitlines():
                if agent_name in line and 'success' in line:
                    return True
        except Exception as e:
            info(f"Log check error: {e}")
    
    # Method 2: Check output file exists and has content
    output_file = LOGS_DIR / f"output-{agent_name}.txt"
    if output_file.exists():
        content = output_file.read_text(encoding='utf-8', errors='replace')
        
        # Agent explicitly said complete
        if "AGENT_COMPLETE" in content:
            return True
        
        # Agent produced substantial output without errors
        if len(content) > 500 and "Traceback" not in content:
            stderr_marker = content.find("---STDERR---")
            if stderr_marker != -1:
                stderr_content = content[stderr_marker:]
                if len(stderr_content) < 200:
                    return True
    
    return False

def run_agent(agent_name, agent_file, context="", config=None, resume=False):
    # Skip completed agents in resume mode
    if resume and check_agent_completed(agent_name):
        print(f"  [{agent_name}] Skipped (already completed) ✓")
        return True
    
    agent_path = AGENTS_DIR / agent_file
    if not agent_path.exists():
        fail(f"{agent_name} - not found: {agent_file}")
        write_log(agent_name, "failed", 0)
        return False
    
    instructions = agent_path.read_text(encoding='utf-8-sig')
    game_project = config.get("project_paths", {}).get("game_project", "../game") if config else "../game"
    
    prompt = f"""You are {agent_name} in Swarn multi-agent system.

## Your Instructions
{instructions}

## Context
- Swarn: {SWARN_DIR}
- Game: {game_project}
- Artifacts: {SWARN_DIR}/artifacts

{context}

Execute your role. Create files. When done, say "AGENT_COMPLETE".
"""
    
    # Save prompt for debugging
    prompt_file = LOGS_DIR / f"prompt-{agent_name}.txt"
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    prompt_file.write_text(prompt, encoding='utf-8')
    
    start = datetime.now()
    print(f"  [{agent_name}] Running...", end="", flush=True)
    
    try:
        # Write prompt to temp file to avoid command line length limits
        import tempfile
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False, encoding='utf-8', dir=str(LOGS_DIR)) as tmp:
            tmp.write(prompt)
            prompt_file = tmp.name
        
        try:
            # Use cmd.exe to pipe file into qwen stdin
            timeout = AGENT_TIMEOUTS.get(agent_name, DEFAULT_TIMEOUT)
            info(f"Timeout: {timeout}s")
            
            cmd = f'type "{prompt_file}" | "{QWEN_CMD}" -y'
            proc = subprocess.run(
                cmd,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=timeout,
                cwd=str(SWARN_DIR)
            )
            result_stdout = proc.stdout.decode('utf-8', errors='replace')
            result_stderr = proc.stderr.decode('utf-8', errors='replace')
            result_code = proc.returncode
        finally:
            Path(prompt_file).unlink(missing_ok=True)
        
        duration = int((datetime.now() - start).total_seconds())
        
        # Save output
        out_text = (result_stdout or "") + "\n\n---STDERR---\n" + (result_stderr or "")
        (LOGS_DIR / f"output-{agent_name}.txt").write_text(out_text, encoding='utf-8')
        
        if result_code == 0:
            print(f" ✓ ({duration}s)")
            write_log(agent_name, "success", duration)
            return True
        else:
            print(f" ✗ ({duration}s)")
            write_log(agent_name, "failed", duration)
            info(f"See: logs/output-{agent_name}.txt")
            return False
            
    except subprocess.TimeoutExpired:
        timeout = AGENT_TIMEOUTS.get(agent_name, DEFAULT_TIMEOUT)
        print(f" ✗ (timeout after {timeout}s)")
        write_log(agent_name, "timeout", timeout)
        return False
    except FileNotFoundError:
        print(" ✗ (qwen not found)")
        write_log(agent_name, "failed", 0, f"qwen not found. Tried: {QWEN_CMD}")
        return False
    except Exception as e:
        print(f" ✗ (error: {e})")
        write_log(agent_name, "failed", 0, str(e))
        return False

PIPELINE = {
    "1": {
        "name": "Concept",
        "agents": [
            ("N1-MarketAnalyst", "market-analyst.md", "Starting fresh."),
            ("N11-NicheAnalyst", "niche-analyst.md", "Prior: market-analysis.json"),
            ("N2-ConceptDesigner", "game-concept-designer.md", "Prior: market-analysis.json, niche-analysis.json"),
        ]
    },
    "2": {
        "name": "Architecture",
        "agents": [
            ("N3-Architect", "game-architect.md", "Prior: gdd.md"),
            ("N15-SeniorTS", "senior-typescript-game-developer.md", "Prior: technical-spec.md"),
        ]
    },
    "3": {
        "name": "Development",
        "agents": [
            ("N4-GameDev", "game-developer.md", "Prior: technical-spec.md"),
            ("N5-UIUX", "ui-ux-designer.md", "Prior: technical-spec.md"),
            ("N6-Level", "level-designer.md", "Prior: technical-spec.md"),
            ("N7-Audio", "audio-engineer.md", "Prior: technical-spec.md"),
            ("N8-Assets", "asset-manager.md", "Prior: technical-spec.md"),
            ("N13-CodeReview", "phaser-code-reviewer.md", "Prior: artifacts/stage-3/src/"),
            ("N17-Docs", "documentation.md", "Prior: all Stage 3"),
        ]
    },
    "4": {
        "name": "Quality",
        "agents": [
            ("N9-QA", "qa-tester.md", "Prior: all Stage 3"),
            ("N10-Perf", "performance-profiler.md", "Prior: test-reports.md"),
            ("N14-PhaserPerf", "phaser-performance-profiler.md", "Prior: test-reports.md"),
            ("N18-Loc", "localization.md", "Prior: UI artifacts"),
        ]
    },
    "5": {
        "name": "Release",
        "agents": [
            ("N16-DevOps", "git-devops.md", "Prior: all Stage 4"),
            ("N19-Marketing", "marketing-launch.md", "Prior: deployment files"),
        ]
    }
}

def run_pipeline(target="all", resume=False):
    if not QWEN_CMD:
        fail("qwen not found! Install it: npm install -g @qwen-code/qwen-code")
        sys.exit(1)
    
    # Add npm dir to PATH for subprocess
    npm_dir = str(Path(QWEN_CMD).parent)
    os.environ["PATH"] = npm_dir + os.pathsep + os.environ.get("PATH", "")
    
    info(f"qwen: {QWEN_CMD}")
    info(f"LOG_FILE: {LOG_FILE}")
    info(f"LOG_FILE exists: {LOG_FILE.exists()}")
    if resume:
        info("Resume mode: skipping completed agents")
        # Show which agents will be skipped
        for stage_info in PIPELINE.values():
            for agent_name, _, _ in stage_info["agents"]:
                if check_agent_completed(agent_name):
                    info(f"  Will skip: {agent_name}")
    
    config = load_config()
    
    stage_msg("=== Swarn Pipeline Runner ===")
    info(f"Swarn: {SWARN_DIR}")
    info(f"Game:  {config.get('project_paths', {}).get('game_project', 'N/A')}")
    info(f"Stage: {target}")
    
    start = datetime.now()
    
    for stage_num, stage_info in PIPELINE.items():
        if target != "all" and target != stage_num:
            continue
        
        stage_msg(f"[Stage {stage_num}: {stage_info['name']}]")
        
        for agent_name, agent_file, context in stage_info["agents"]:
            if not run_agent(agent_name, agent_file, context, config, resume):
                fail(f"Pipeline FAILED at {agent_name}")
                sys.exit(1)
        
        success(f"Stage {stage_num} Complete")
    
    minutes = int((datetime.now() - start).total_seconds() / 60)
    
    stage_msg("=== PIPELINE COMPLETE! ===")
    info(f"Time: {minutes} minutes")
    info(f"Artifacts: {SWARN_DIR / 'artifacts'}")
    info(f"Logs: {LOG_FILE}")

if __name__ == "__main__":
    target = "all"
    resume = False
    
    for arg in sys.argv[1:]:
        if arg.startswith("--stage"):
            target = arg.split("=")[1] if "=" in arg else sys.argv[sys.argv.index(arg) + 1] if sys.argv.index(arg) + 1 < len(sys.argv) else "all"
        elif arg == "--resume":
            resume = True
        elif arg == "--help":
            print("Usage: python run-pipeline.py [--stage=N] [--resume]")
            print("  --stage=N   Run only stage N (1-5)")
            print("  --resume    Skip completed agents")
            sys.exit(0)
    
    run_pipeline(target, resume)
