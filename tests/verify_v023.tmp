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
    "scripts/touch_playtest.gd",
    "tests/gameplay_smoke.gd",
    "web/patch_mobile_shell.py",
    "export_presets.cfg",
    "docs/GAME_DESIGN.md",
    "docs/ART_DIRECTION.md",
    "docs/RELEASE_ROADMAP.md",
    "docs/QA_MATRIX.md",
    "CHANGELOG.md",
]
missing = [p for p in required if not (root / p).exists()]
assert not missing, f"Missing required project files: {missing}"

project = (root / "project.godot").read_text(encoding="utf-8")
assert 'config/name="Blackroot Hollow"' in project
assert 'AudioManager="*res://scripts/audio_manager.gd"' in project
assert 'TouchPlaytest="*res://scripts/touch_playtest.gd"' in project

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
for token in ["try_dodge", "try_dodge_direction", "dodge_timer", "dodge_input_locked", "_begin_dodge"]:
    assert token in player

enemy = (root / "scripts/enemy.gd").read_text(encoding="utf-8")
for token in ["hit_flash_timer", "blackroot_enemies", "_apply_separation"]:
    assert token in enemy

touch = (root / "scripts/touch_playtest.gd").read_text(encoding="utf-8")
for token in ["InputEventScreenTouch", "InputEventScreenDrag", "ATTACK", "DODGE", "PAUSE", "gameplay_panel_style", "NOTIFICATION_APPLICATION_FOCUS_OUT", "try_dodge_direction"]:
    assert token in touch

smoke = (root / "tests/gameplay_smoke.gd").read_text(encoding="utf-8")
for token in ["InputEventScreenTouch", "InputEventScreenDrag", "touch dodge follows active thumb direction", "held desktop dodge does not auto-repeat", "overlapping enemies separate", "BLACKROOT GAMEPLAY SMOKE PASSED"]:
    assert token in smoke

shell = (root / "web/patch_mobile_shell.py").read_text(encoding="utf-8")
assert "blackroot-mobile-landscape" in shell
assert "Rotate your phone to landscape" in shell
assert "safe-area-inset-left" in shell
assert "safe-area-inset-right" in shell

preset = (root / "export_presets.cfg").read_text(encoding="utf-8")
assert 'platform="Windows Desktop"' in preset
assert 'platform="Web"' in preset
assert 'application/product_version="0.2.3.0"' in preset

for staging in root.rglob("*_v023.tmp"):
    raise AssertionError(f"Staging file leaked into release tree: {staging.relative_to(root)}")

print("Blackroot Hollow 0.2.3 structural verification passed.")
