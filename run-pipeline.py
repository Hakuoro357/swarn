#!/usr/bin/env python3
"""
Swarn Pipeline Runner
Usage: python run-pipeline.py [--stage N]
"""

import subprocess
import sys
import json
import os
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

def run_agent(agent_name, agent_file, context="", config=None):
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
        result = subprocess.run(
            ["qwen", prompt, "-y"],
            capture_output=True,
            text=True,
            timeout=600,
            cwd=str(SWARN_DIR)
        )
        
        duration = int((datetime.now() - start).total_seconds())
        
        # Save output
        (LOGS_DIR / f"output-{agent_name}.txt").write_text(
            result.stdout + "\n\n---STDERR---\n" + result.stderr,
            encoding='utf-8'
        )
        
        if result.returncode == 0:
            print(f" ✓ ({duration}s)")
            write_log(agent_name, "success", duration)
            return True
        else:
            print(f" ✗ ({duration}s)")
            write_log(agent_name, "failed", duration)
            info(f"See: logs/output-{agent_name}.txt")
            return False
            
    except subprocess.TimeoutExpired:
        print(" ✗ (timeout)")
        write_log(agent_name, "timeout", 600)
        return False
    except FileNotFoundError:
        print(" ✗ (qwen not found)")
        write_log(agent_name, "failed", 0)
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

def run_pipeline(target="all"):
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
            if not run_agent(agent_name, agent_file, context, config):
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
    if len(sys.argv) > 1 and sys.argv[1].startswith("--stage"):
        target = sys.argv[1].split("=")[1] if "=" in sys.argv[1] else sys.argv[2] if len(sys.argv) > 2 else "all"
    
    run_pipeline(target)
