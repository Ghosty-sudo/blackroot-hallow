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
    "scripts/menu_focus.gd",
    "tests/gameplay_smoke.gd",
    "web/patch_mobile_shell.py",
    "export_presets.cfg",
    "default_bus_layout.tres",
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
assert 'MenuFocus="*res://scripts/menu_focus.gd"' in project

save = (root / "scripts/save_manager.gd").read_text(encoding="utf-8")
assert "CURRENT_SAVE_VERSION := 2" in save
assert "SAVE_BACKUP_PATH" in save
for token in ['"tutorial_seen"', '"sfx_volume"', "last_load_notice", "last_save_error"]:
    assert token in save

audio = (root / "scripts/audio_manager.gd").read_text(encoding="utf-8")
assert 'player.bus = "SFX"' in audio
bus_layout = (root / "default_bus_layout.tres").read_text(encoding="utf-8")
assert 'bus/1/name = &"SFX"' in bus_layout
assert 'bus/1/send = &"Master"' in bus_layout

focus = (root / "scripts/menu_focus.gd").read_text(encoding="utf-8")
for token in ["gui_get_focus_owner", "grab_focus", "last_load_notice"]:
    assert token in focus

game = (root / "scripts/game.gd").read_text(encoding="utf-8")
for weapon in ["Warden Blade", "Root Pike", "Grave Cleaver"]:
    assert weapon in game
for token in [
    "briar_warden",
    "_dodge_pressed",
    "_show_pause_menu",
    "RETRY — SAME LOADOUT",
    "DESCEND AGAIN — SAME LOADOUT",
    "SFX VOLUME",
    "HP_UPGRADE_CAP",
    "DAMAGE_UPGRADE_CAP",
    "run_banked_amber",
]:
    assert token in game
assert "technical loop is complete" not in game.lower()

player = (root / "scripts/player.gd").read_text(encoding="utf-8")
for token in ["try_dodge", "try_dodge_direction", "dodge_timer", "dodge_input_locked", "_begin_dodge"]:
    assert token in player

enemy = (root / "scripts/enemy.gd").read_text(encoding="utf-8")
for token in ["hit_flash_timer", "blackroot_enemies", "_apply_separation"]:
    assert token in enemy

touch = (root / "scripts/touch_playtest.gd").read_text(encoding="utf-8")
for token in ["InputEventScreenTouch", "InputEventScreenDrag", "ATTACK", "DODGE", "PAUSE", "gameplay_panel_style", "NOTIFICATION_APPLICATION_FOCUS_OUT", "try_dodge_direction", "combat_active"]:
    assert token in touch

smoke = (root / "tests/gameplay_smoke.gd").read_text(encoding="utf-8")
for token in [
    "opening presents clear begin action",
    "pause offers resume",
    "settings expose SFX volume",
    "death screen offers immediate retry",
    "victory screen offers replay with same loadout",
    "touch dodge follows active thumb direction",
    "held desktop dodge does not auto-repeat",
    "overlapping enemies separate",
    "BLACKROOT GAMEPLAY SMOKE PASSED",
]:
    assert token in smoke

shell = (root / "web/patch_mobile_shell.py").read_text(encoding="utf-8")
assert "blackroot-mobile-landscape" in shell
assert "Rotate your phone to landscape" in shell
assert "safe-area-inset-left" in shell
assert "safe-area-inset-right" in shell

preset = (root / "export_presets.cfg").read_text(encoding="utf-8")
assert 'platform="Windows Desktop"' in preset
assert 'platform="Web"' in preset
assert 'application/product_version="0.2.4.0"' in preset

for staging in root.rglob("*.tmp"):
    raise AssertionError(f"Staging file leaked into release tree: {staging.relative_to(root)}")

print("Blackroot Hollow 0.2.4 structural verification passed.")
