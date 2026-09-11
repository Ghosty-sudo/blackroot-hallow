extends SceneTree

var failures := 0
const GAME_SIZE := Vector2(320.0, 180.0)

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String) -> void:
    if condition:
        print("PASS: " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)

func _screen_from_game(game_position: Vector2) -> Vector2:
    var visible_size := root.get_visible_rect().size
    if visible_size.x <= 0.0 or visible_size.y <= 0.0 or visible_size.is_equal_approx(GAME_SIZE):
        return game_position
    var fit_scale := minf(visible_size.x / GAME_SIZE.x, visible_size.y / GAME_SIZE.y)
    var rendered_size := GAME_SIZE * fit_scale
    var offset := (visible_size - rendered_size) * 0.5
    return offset + game_position * fit_scale

func _touch_event(index: int, game_position: Vector2, pressed: bool) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = index
    event.position = _screen_from_game(game_position)
    event.pressed = pressed
    return event

func _drag_event(index: int, game_position: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = index
    event.position = _screen_from_game(game_position)
    return event

func _menu_contains(game: Node, needle: String) -> bool:
    var menu: Variant = game.get("menu_box")
    if not (menu is VBoxContainer):
        return false
    for child: Node in (menu as VBoxContainer).get_children():
        if child is Button and needle in (child as Button).text:
            return true
    return false

func _clear_live_enemies(game: Node) -> void:
    var current_enemies: Array = game.get("enemies")
    for enemy: Node in current_enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    current_enemies.clear()

func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check(packed != null, "main scene loads")
    if packed == null:
        quit(1)
        return

    var game := packed.instantiate()
    root.add_child(game)
    current_scene = game
    await process_frame

    _check(int(game.get("state")) == 0, "title state boots")
    _check(_menu_contains(game, "BEGIN"), "opening presents clear begin action")
    game.call("_show_hub")
    _check(_menu_contains(game, "DESCEND"), "hub presents clear descend action")
    _check(int(game.call("_hp_upgrade_cost")) >= 8, "vitality upgrade has explicit cost")
    _check(int(game.call("_damage_upgrade_cost")) >= 10, "damage upgrade has explicit cost")

    game.call("_show_weapons")
    var weapons: Array = game.get("weapons")
    _check(weapons.size() == 3, "three distinct weapon choices available")
    game.call("_choose_weapon", weapons[0])
    var marks: Array = game.get("marks")
    _check(marks.size() == 3, "three Rootmark bargains available")
    game.call("_start_run", marks[0])
    await process_frame

    var player: Node2D = game.get("player")
    _check(int(game.get("state")) == 4 and player != null, "expedition starts with player")

    game.call("_toggle_pause")
    _check(paused, "pause suspends gameplay")
    for label in ["RESUME", "RESTART", "SETTINGS", "ABANDON"]:
        _check(_menu_contains(game, label), "pause offers " + label.to_lower())
    game.call("_show_settings")
    _check(_menu_contains(game, "SFX VOLUME"), "settings expose SFX volume")
    game.call("_leave_settings")
    _check(int(game.get("state")) == 4 and paused, "back from run settings restores pause")
    game.call("_resume_run")
    _check(not paused, "resume returns to gameplay")

    var touch := root.get_node_or_null("TouchPlaytest")
    _check(touch != null, "touch adapter autoload exists")
    if player != null and touch != null:
        touch.set("touch_device", true)
        if touch.get("hud") == null:
            touch.call("_build_hud")
        touch.call("_process", 0.0)
        var root_ui: CanvasLayer = game.get("root_ui")
        var desktop_panel := root_ui.get_child(0) as PanelContainer
        _check(not desktop_panel.visible, "mobile combat removes desktop panel from battlefield")
        var mobile_status: Variant = touch.get("status_label")
        _check(mobile_status is Label and "HP" in (mobile_status as Label).text and "AMBER" in (mobile_status as Label).text, "mobile combat uses compact status HUD")

        var before_touch := player.position
        touch.call("_input", _touch_event(1, Vector2(35, 145), true))
        touch.call("_input", _drag_event(1, Vector2(67, 145)))
        touch.call("_process", 0.10)
        touch.call("_input", _touch_event(1, Vector2(67, 145), false))
        _check(player.position.x > before_touch.x, "screen-drag movement moves player")
        var enemies: Array = game.get("enemies")
        if enemies.size() > 0:
            var enemy: Node2D = enemies[0]
            player.set("facing", Vector2.RIGHT)
            enemy.position = player.position + Vector2(13, 0)
            var hp_before := int(enemy.get("hp"))
            player.set("attack_cooldown", 0.0)
            touch.call("_input", _touch_event(2, Vector2(286, 146), true))
            touch.call("_input", _touch_event(2, Vector2(286, 146), false))
            _check(int(enemy.get("hp")) < hp_before, "touch attack damages enemy")
            _check(float(enemy.get("hit_flash_timer")) > 0.0, "enemy hit feedback starts")
        player.set("dodge_cooldown", 0.0)
        player.set("dodge_timer", 0.0)
        player.set("facing", Vector2.UP)
        touch.call("_input", _touch_event(6, Vector2(35, 145), true))
        touch.call("_input", _drag_event(6, Vector2(67, 145)))
        touch.call("_input", _touch_event(3, Vector2(230, 152), true))
        _check(Vector2(player.get("dodge_direction")).x > 0.8, "touch dodge follows active thumb direction")
        touch.call("_input", _touch_event(3, Vector2(230, 152), false))
        touch.call("_input", _touch_event(6, Vector2(67, 145), false))

        game.call("_toggle_pause")
        touch.call("_process", 0.0)
        _check(desktop_panel.visible, "pause restores full menu panel on mobile")
        game.call("_resume_run")
        touch.call("_process", 0.0)
        _check(not desktop_panel.visible, "resume returns to compact mobile combat HUD")

    _check(String(game.call("_guardian_kind_for_depth", 1)) == "briar_warden", "depth one uses Briar Warden")
    _check(String(game.call("_guardian_kind_for_depth", 2)) == "marrow_bell", "depth two uses Marrow Bell")
    _check(String(game.call("_guardian_kind_for_depth", 3)) == "ember_stag", "depth three uses Ember Stag")
    var relic_pool: Array = game.get("relic_pool")
    _check(relic_pool.size() == 6, "six coherent relic effects form the run pool")

    game.set("wave", 4)
    game.set("run_amber", 7)
    game.call("_advance_encounter")
    await process_frame
    _check(int(game.get("state")) == 8, "first guardian clear opens relic choice")
    _check(int(game.get("depth")) == 2, "relic choice occurs before depth two")
    var relic_options: Array = game.get("relic_options")
    _check(relic_options.size() == 3, "relic choice presents three options")
    player = game.get("player")
    var hp_before_relic := int(player.get("max_hp"))
    game.call("_choose_relic", relic_pool[0])
    await process_frame
    _check(int(game.get("state")) == 4, "relic choice resumes expedition")
    _check(int(player.get("max_hp")) == hp_before_relic + 2, "Thorn Heart changes player build")
    _check(Array(game.get("run_relics")).size() == 1, "chosen relic is tracked in run identity")
    _check(int(game.get("wave")) == 1, "next biome begins after relic choice")

    _clear_live_enemies(game)
    game.set("wave", 3)
    game.call("_advance_encounter")
    await process_frame
    var enemies_after: Array = game.get("enemies")
    _check(enemies_after.size() == 1 and String(enemies_after[0].get("archetype")) == "marrow_bell", "depth two guardian is mechanically distinct")
    _clear_live_enemies(game)
    game.call("_advance_encounter")
    await process_frame
    _check(int(game.get("state")) == 8 and int(game.get("depth")) == 3, "second guardian clear opens final relic choice")
    game.call("_choose_relic", relic_pool[1])
    await process_frame
    _check(Array(game.get("run_relics")).size() == 2, "run carries two relics into final depth")

    player = game.get("player")
    game.set("run_amber", 6)
    game.set("run_kills", 4)
    player.set("hurt_cooldown", 0.0)
    player.set("dodge_timer", 0.0)
    player.call("take_damage", 999)
    await process_frame
    _check(int(game.get("state")) == 5, "lethal damage reaches game-over state")
    _check(_menu_contains(game, "RETRY"), "death screen offers immediate retry")
    game.call("_retry_same_loadout")
    await process_frame
    _check(int(game.get("state")) == 4 and Array(game.get("run_relics")).is_empty(), "retry starts a clean run build")

    _clear_live_enemies(game)
    game.set("depth", 3)
    game.set("wave", 3)
    game.call("_advance_encounter")
    await process_frame
    var final_enemies: Array = game.get("enemies")
    _check(final_enemies.size() == 1 and String(final_enemies[0].get("archetype")) == "ember_stag", "final depth uses Ember Stag guardian")
    _clear_live_enemies(game)
    game.call("_advance_encounter")
    await process_frame
    _check(int(game.get("state")) == 6, "final guardian clear reaches victory")
    _check(_menu_contains(game, "DESCEND AGAIN"), "victory offers replay")
    var victory_info: Variant = game.get("info_label")
    if victory_info is Label:
        _check(not "technical loop" in (victory_info as Label).text.to_lower(), "victory has no developer-facing residue")

    var exit_code := 0
    if failures == 0:
        print("BLACKROOT GAMEPLAY SMOKE PASSED")
    else:
        push_error("BLACKROOT GAMEPLAY SMOKE FAILED: %d checks failed" % failures)
        exit_code = 1
    current_scene = null
    game.queue_free()
    await process_frame
    await process_frame
    quit(exit_code)
