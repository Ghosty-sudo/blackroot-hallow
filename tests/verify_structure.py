from pathlib import Path

root = Path(__file__).resolve().parents[1]

required = [
    "project.godot",
    "scenes/main.tscn",
    "scripts/game.gd",
    "scripts/player.gd",
    "scripts/enemy.gd",
    "scripts/save_manager.gd",
    "scripts/audio_manager.gd",
    "export_presets.cfg",
    "docs/GAME_DESIGN.md",
    "docs/ART_DIRECTION.md",
    "docs/RELEASE_ROADMAP.md",
    "CHANGELOG.md",
]
missing = [p for p in required if not (root / p).exists()]
assert not missing, f"Missing required project files: {missing}"

project = (root / "project.godot").read_text(encoding="utf-8")
assert 'config/name="Blackroot Hollow"' in project
assert 'AudioManager="*res://scripts/audio_manager.gd"' in project

save = (root / "scripts/save_manager.gd").read_text(encoding="utf-8")
assert "CURRENT_SAVE_VERSION := 2" in save
assert "SAVE_BACKUP_PATH" in save
assert '"tutorial_seen"' in save

game = (root / "scripts/game.gd").read_text(encoding="utf-8")
for weapon in ["Warden Blade", "Root Pike", "Grave Cleaver"]:
    assert weapon in game
assert "briar_warden" in game
assert "_dodge_pressed" in game

player = (root / "scripts/player.gd").read_text(encoding="utf-8")
assert "try_dodge" in player
assert "dodge_timer" in player

preset = (root / "export_presets.cfg").read_text(encoding="utf-8")
assert 'platform="Windows Desktop"' in preset
assert 'application/product_version="0.2.0.0"' in preset

print("Blackroot Hollow 0.2.0 structural verification passed.")
