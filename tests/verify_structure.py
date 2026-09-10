from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = [
    "project.godot", "scenes/main.tscn", "scripts/game.gd", "scripts/player.gd",
    "scripts/enemy.gd", "scripts/save_manager.gd", "scripts/audio_manager.gd",
    "scripts/touch_playtest.gd", "scripts/menu_focus.gd", "tests/gameplay_smoke.gd",
    "web/patch_mobile_shell.py", "export_presets.cfg", "default_bus_layout.tres",
    "docs/GAME_DESIGN.md", "docs/ART_DIRECTION.md", "docs/RELEASE_ROADMAP.md",
    "docs/QA_MATRIX.md", "CHANGELOG.md",
]
missing = [p for p in required if not (root / p).exists()]
assert not missing, f"Missing required project files: {missing}"

project = (root / "project.godot").read_text(encoding="utf-8")
for token in ['config/name="Blackroot Hollow"', 'AudioManager="*res://scripts/audio_manager.gd"', 'TouchPlaytest="*res://scripts/touch_playtest.gd"', 'MenuFocus="*res://scripts/menu_focus.gd"']:
    assert token in project

save = (root / "scripts/save_manager.gd").read_text(encoding="utf-8")
for token in ["SAVE_BACKUP_PATH", '"sfx_volume"', "last_load_notice", "last_save_error"]:
    assert token in save

audio = (root / "scripts/audio_manager.gd").read_text(encoding="utf-8")
assert 'player.bus = "SFX"' in audio
bus_layout = (root / "default_bus_layout.tres").read_text(encoding="utf-8")
assert 'bus/1/name = &"SFX"' in bus_layout

game = (root / "scripts/game.gd").read_text(encoding="utf-8")
for token in [
    "STATE_RELICS", "Thorn Heart", "Keen Resin", "Hollow Step", "Sapglass Fang",
    "Warden Knot", "Longroot Grip", "_show_relic_choice", "_choose_relic",
    "briar_warden", "marrow_bell", "ember_stag", "_guardian_kind_for_depth",
    "_show_pause_menu", "RETRY — SAME LOADOUT", "SFX VOLUME", "HP_UPGRADE_CAP",
    "DAMAGE_UPGRADE_CAP", "run_banked_amber", "run_relics",
]:
    assert token in game
assert "technical loop is complete" not in game.lower()

player = (root / "scripts/player.gd").read_text(encoding="utf-8")
for token in ["apply_relic", "thorn_heart", "keen_resin", "hollow_step", "sapglass_fang", "warden_knot", "longroot_grip", "dodge_cooldown_max"]:
    assert token in player

enemy = (root / "scripts/enemy.gd").read_text(encoding="utf-8")
for token in ["marrow_bell", "ember_stag", "_process_marrow_bell", "_process_ember_stag", "hit_flash_timer", "_apply_separation"]:
    assert token in enemy

touch = (root / "scripts/touch_playtest.gd").read_text(encoding="utf-8")
for token in ["InputEventScreenTouch", "InputEventScreenDrag", "NOTIFICATION_APPLICATION_FOCUS_OUT", "try_dodge_direction", "combat_active"]:
    assert token in touch

smoke = (root / "tests/gameplay_smoke.gd").read_text(encoding="utf-8")
for token in ["first guardian clear opens relic choice", "depth two guardian is mechanically distinct", "final depth uses Ember Stag guardian", "retry starts a clean run build", "BLACKROOT GAMEPLAY SMOKE PASSED"]:
    assert token in smoke

preset = (root / "export_presets.cfg").read_text(encoding="utf-8")
assert 'platform="Windows Desktop"' in preset and 'platform="Web"' in preset
assert 'application/product_version="0.3.0.0"' in preset

for staging in root.rglob("*.tmp"):
    raise AssertionError(f"Staging file leaked into release tree: {staging.relative_to(root)}")

print("Blackroot Hollow 0.3.0 structural verification passed.")
