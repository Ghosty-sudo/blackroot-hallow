from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
required = [
    "project.godot",
    "scenes/main.tscn",
    "scripts/game.gd",
    "scripts/player.gd",
    "scripts/enemy.gd",
    "scripts/save_manager.gd",
    "export_presets.cfg",
    "docs/GAME_DESIGN.md",
    "docs/RELEASE_ROADMAP.md",
]
missing = [p for p in required if not (root / p).exists()]
assert not missing, f"Missing required project files: {missing}"
project = (root / "project.godot").read_text(encoding="utf-8")
assert 'config/name="Blackroot Hollow"' in project
save = (root / "scripts/save_manager.gd").read_text(encoding="utf-8")
assert '"version": 1' in save
preset = (root / "export_presets.cfg").read_text(encoding="utf-8")
assert 'platform="Windows Desktop"' in preset
print("Blackroot Hollow structural verification passed.")
