extends "res://scripts/game.gd"

const STATE_STORY := 9
const HEARTWOOD_DEPTH := 4

var heartwood_active := false
var sentinel_active := false
var sentinel_phase_seen := 0
var story_sequence: Array[Dictionary] = []
var story_index := 0
var story_done: Callable = Callable()
var story_screen_title := ""
var story_screen_subtitle := ""

func current_story_stage() -> Dictionary:
    return BlackrootStoryRoute.next_unfinished(SaveManager.story_flags())

func _process(delta: float) -> void:
    super._process(delta)
    if sentinel_active and state == STATE_RUN:
        _update_sentinel_story_barks()

func _show_hub() -> void:
    heartwood_active = false
    sentinel_active = false
    super._show_hub()
    var flags := SaveManager.story_flags()
    var voice := BlackrootStoryCatalog.hub_voice(flags, int(SaveManager.save_data.get("wins", 0)))
    var speaker := String(voice.get("speaker", ""))
    var text := String(voice.get("text", ""))
    if not speaker.is_empty() and not text.is_empty():
        info_label.text += "\n%s: %s" % [speaker, text]
    if bool(flags.get(BlackrootStoryCatalog.FLAG_MEASURED_CUT, false)) and menu_box.get_child_count() > 0:
        var first := menu_box.get_child(0)
        if first is Button:
            (first as Button).text = "BEGIN COVENANT PATROL"
        footer_label.text = "Patrol the repaired covenant paths. Take only what the Hollow can shed."

func _show_marks() -> void:
    super._show_marks()
    subtitle_label.text = "Every gift from the Hollow moves a cost somewhere else."
    footer_label.text = "The curse is the price of the blessing, not flavor text."

func _start_run(mark: Dictionary) -> void:
    heartwood_active = false
    sentinel_active = false
    sentinel_phase_seen = 0
    var tutorial_was_seen := bool(SaveManager.save_data.get("tutorial_seen", false))
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_FIRST_DESCENT, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_FIRST_DESCENT)
    super._start_run(mark)
    if tutorial_was_seen:
        if bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_MEASURED_CUT, false)):
            message = "COVENANT PATROL — clear damaged memories; take only what can be returned."
        else:
            message = BlackrootStoryCatalog.rootmark_lore(String(mark.get("name", "")))
        banner_timer = 4.2
        _refresh_info()

func _advance_encounter() -> void:
    if sentinel_active:
        sentinel_active = false
        _begin_sentinel_defeat()
        return

    var cleared_guardian := wave > 0 and wave % 4 == 0
    var cleared_depth := depth
    if cleared_guardian and cleared_depth == 3 and not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_MEASURED_CUT, false)):
        _bank_third_guardian_and_open_heartwood()
        return

    super._advance_encounter()
    if not cleared_guardian:
        return
    _apply_guardian_reveal(cleared_depth)

func _apply_guardian_reveal(cleared_depth: int) -> void:
    var reveal := BlackrootStoryCatalog.guardian_reveal(cleared_depth)
    if reveal.is_empty():
        return
    var flag := String(reveal.get("flag", ""))
    var already_seen := bool(SaveManager.story_flags().get(flag, false))
    if already_seen:
        return
    SaveManager.set_story_flag(flag)
    var speaker := String(reveal.get("speaker", "ROOTVOICE"))
    var text := String(reveal.get("text", ""))
    if state == STATE_RELICS:
        info_label.text = "%s: %s\n\n%s" % [speaker, text, info_label.text]
    elif state == STATE_VICTORY:
        info_label.text += "\n%s: %s" % [speaker, text]

func _bank_third_guardian_and_open_heartwood() -> void:
    SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) + run_amber
    run_banked_amber += run_amber
    run_amber = 0
    SaveManager.save_data["best_depth"] = maxi(int(SaveManager.save_data.get("best_depth", 0)), 3)
    var reveal := BlackrootStoryCatalog.guardian_reveal(3)
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_EMBER_TRUTH, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_EMBER_TRUTH)
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN)
    SaveManager.save_progress()
    var opening: Array[Dictionary] = []
    opening.append({"speaker": String(reveal.get("speaker", "ROOTVOICE")), "text": String(reveal.get("text", ""))})
    opening.append({"speaker": "", "text": "The third seal opens beneath Embermold. The route does not climb toward Warden's Rest. It continues down."})
    _show_story_sequence("THE THIRD SEAL BREAKS", "Briar, bone, and ember fall quiet. Something deeper answers.", opening, _begin_heartwood_entry)

func _begin_heartwood_entry() -> void:
    heartwood_active = true
    _show_story_sequence("HEARTWOOD THRESHOLD", "The old covenant path recognizes the Rootmark before it recognizes you.", BlackrootStoryCatalog.heartwood_entry(), _begin_heartwood_memories)

func _begin_heartwood_memories() -> void:
    var memories: Array[Dictionary] = []
    for memory: Dictionary in BlackrootStoryCatalog.heartwood_memories():
        memories.append({"speaker": "ROOT-MEMORY", "text": String(memory.get("text", ""))})
    _show_story_sequence("THE FIRST MEASURE", "The chamber does not explain. It remembers.", memories, _begin_sentinel)

func _begin_sentinel() -> void:
    heartwood_active = true
    sentinel_active = true
    sentinel_phase_seen = 0
    state = STATE_RUN
    depth = HEARTWOOD_DEPTH
    wave = 1
    _clear_menu()
    title_label.text = "HEARTWOOD CHAMBER"
    subtitle_label.text = "HEARTWOOD SENTINEL — Keeper of the First Measure"
    if is_instance_valid(player):
        player.hp = player.max_hp
        player.hp_changed.emit(player.hp, player.max_hp)
        player.position = Vector2(160, 132)
    var lines := BlackrootStoryCatalog.sentinel_lines()
    message = String(lines.get("intro", "WARDEN."))
    banner_timer = 5.0
    _spawn_enemy("heartwood_sentinel", Vector2(160, 58))
    _refresh_info()

func _update_sentinel_story_barks() -> void:
    var sentinel: BlackrootEnemy = null
    for enemy: BlackrootEnemy in enemies:
        if is_instance_valid(enemy) and enemy.archetype == "heartwood_sentinel":
            sentinel = enemy
            break
    if sentinel == null or sentinel.max_hp <= 0:
        return
    var ratio := float(sentinel.hp) / float(sentinel.max_hp)
    var next_phase := 0
    if ratio <= 0.33:
        next_phase = 3
    elif ratio <= 0.66:
        next_phase = 2
    elif ratio <= 0.86:
        next_phase = 1
    if next_phase <= sentinel_phase_seen:
        return
    sentinel_phase_seen = next_phase
    var lines := BlackrootStoryCatalog.sentinel_lines()
    var key := "phase_%d" % next_phase
    message = String(lines.get(key, ""))
    if next_phase == 3:
        message += "  " + String(lines.get("final_phase", ""))
    banner_timer = 4.0
    _refresh_info()

func _begin_sentinel_defeat() -> void:
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED)
    SaveManager.save_progress()
    var lines := BlackrootStoryCatalog.sentinel_lines()
    _show_story_sequence("KEEPER YIELDS", "The Sentinel lowers its weapon. The chamber remains alive.", [{"speaker":"ROOTVOICE", "text":String(lines.get("defeat", ""))}], _begin_confrontation)

func _begin_confrontation() -> void:
    _show_story_sequence("NO CLEAN VICTORY", "Both sides still have a weapon pointed at the future.", BlackrootStoryCatalog.heartwood_confrontation(), _show_measured_cut_choice)

func _show_measured_cut_choice() -> void:
    state = STATE_STORY
    _clear_menu()
    title_label.text = "THE MEASURED CUT"
    subtitle_label.text = "Refuse conquest. Refuse annihilation. Cut the machinery that turned covenant into extraction."
    info_label.text = "Sever the forced Amber channels, preserve the original path, and carry the buried history back to Warden's Rest."
    _button("SEVER THE TAKING — LEAVE THE PATH", _commit_measured_cut)
    footer_label.text = "This is Blackroot Hollow's launch ending."
    queue_redraw()

func _commit_measured_cut() -> void:
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_MEASURED_CUT, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_MEASURED_CUT)
        SaveManager.save_data["wins"] = int(SaveManager.save_data.get("wins", 0)) + 1
    last_run_depth = HEARTWOOD_DEPTH
    last_run_kills = run_kills
    last_run_amber_banked = run_banked_amber
    last_run_relics = run_relics.duplicate()
    SaveManager.save_progress()
    _show_story_sequence("THE TAKING IS CUT", "The Heartwood recoils — then realizes what remains.", BlackrootStoryCatalog.measured_cut_lines(), _begin_epilogue)

func _begin_epilogue() -> void:
    _show_story_sequence("WARDEN'S REST — AFTER", "The archive opens. The ration tables change. Nobody gets to call repair a victory and stop measuring.", BlackrootStoryCatalog.ending_epilogue(), _finish_story)

func _finish_story() -> void:
    state = STATE_VICTORY
    heartwood_active = false
    sentinel_active = false
    _clear_world()
    _clear_menu()
    title_label.text = "COVENANT RESTORED"
    subtitle_label.text = "The Measured Cut leaves a road in both directions."
    info_label.text = "Story complete • Defeated %d • Amber secured %d • Relics %d\nFuture descents are covenant patrols: clear damaged memories, protect the route, and take only what can be returned." % [last_run_kills, last_run_amber_banked, last_run_relics.size()]
    _button("BEGIN COVENANT PATROL — SAME LOADOUT", _retry_same_loadout)
    _button("RETURN TO WARDEN'S REST", _show_hub)
    _button("TITLE", _show_title)
    footer_label.text = "The ending persists. Patrols continue without undoing it."
    queue_redraw()

func _show_story_sequence(screen_title: String, screen_subtitle: String, lines: Array[Dictionary], done: Callable) -> void:
    state = STATE_STORY
    story_screen_title = screen_title
    story_screen_subtitle = screen_subtitle
    story_sequence = lines.duplicate(true)
    story_index = 0
    story_done = done
    _render_story_step()

func _render_story_step() -> void:
    _clear_menu()
    title_label.text = story_screen_title
    subtitle_label.text = story_screen_subtitle
    if story_index >= story_sequence.size():
        var done := story_done
        story_done = Callable()
        if done.is_valid():
            done.call()
        return
    var line: Dictionary = story_sequence[story_index]
    var speaker := String(line.get("speaker", ""))
    var text := String(line.get("text", ""))
    info_label.text = text if speaker.is_empty() else "%s: %s" % [speaker, text]
    _button("CONTINUE", _advance_story_step)
    footer_label.text = "%d/%d" % [story_index + 1, story_sequence.size()]
    queue_redraw()

func _advance_story_step() -> void:
    story_index += 1
    _render_story_step()

func _on_player_died() -> void:
    if not heartwood_active:
        super._on_player_died()
        return
    var recovered := int(run_amber / 2)
    SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) + recovered
    SaveManager.save_progress()
    last_run_depth = HEARTWOOD_DEPTH
    last_run_kills = run_kills
    last_run_amber_banked = run_banked_amber + recovered
    last_run_relics = run_relics.duplicate()
    state = STATE_GAMEOVER
    heartwood_active = false
    sentinel_active = false
    _clear_world()
    _clear_menu()
    title_label.text = "THE COVENANT PATH RETURNS YOU"
    subtitle_label.text = "The Rootmark finds the road home before the Sentinel finishes the lesson."
    info_label.text = "Reached Heartwood • Defeated %d • Amber secured %d • Relics %d\nThe third seal remains open. Retry the expedition when you're ready." % [last_run_kills, last_run_amber_banked, last_run_relics.size()]
    _button("RETRY — SAME LOADOUT", _retry_same_loadout)
    _button("RETURN TO WARDEN'S REST", _show_hub)
    footer_label.text = "Story discoveries persist; the combat run restarts."

func _show_pause_menu() -> void:
    super._show_pause_menu()
    if heartwood_active and is_instance_valid(player):
        info_label.text = "HP %d/%d • HEARTWOOD • Sentinel phase %d • Unbanked Amber %d\nRelics: %s" % [player.hp, player.max_hp, maxi(1, sentinel_phase_seen), run_amber, "None" if run_relics.is_empty() else ", ".join(run_relics)]

func _restore_run_ui() -> void:
    if not heartwood_active:
        super._restore_run_ui()
        return
    _clear_menu()
    title_label.text = "HEARTWOOD CHAMBER"
    subtitle_label.text = "HEARTWOOD SENTINEL — Keeper of the First Measure"
    footer_label.text = "Read the tell • dodge the measure • survive the lesson"
    _refresh_info()

func _refresh_info() -> void:
    if not heartwood_active:
        super._refresh_info()
        return
    if state != STATE_RUN or not is_instance_valid(player):
        return
    var suffix := " • " + message if not message.is_empty() else ""
    info_label.text = "HP %d/%d • HEARTWOOD • Unbanked %d • Relics %d • Enemies %d%s" % [player.hp, player.max_hp, run_amber, run_relics.size(), enemies.size(), suffix]

func _show_victory() -> void:
    # Kept for compatibility with tests/tools that call the old three-depth endpoint.
    # A real story run reaches the final act through _bank_third_guardian_and_open_heartwood.
    state = STATE_VICTORY
    _clear_world()
    _clear_menu()
    title_label.text = "THE THIRD SEAL BREAKS"
    subtitle_label.text = "The old endpoint is now a threshold."
    info_label.text = "The playable story continues through Heartwood, the Sentinel, and the Measured Cut."
    _button("RETURN TO WARDEN'S REST", _show_hub)
    footer_label.text = "Runtime clears no longer stop here."

func _draw() -> void:
    var environment_id := _current_environment_id()
    if not high_contrast and not environment_id.is_empty():
        var profile := BlackrootArtCatalog.profile("environment", environment_id)
        var texture_path := String(profile.get("texture", ""))
        if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
            var resource := load(texture_path)
            if resource is Texture2D:
                draw_texture_rect(resource as Texture2D, Rect2(0, 0, 320, 180), false)
                _draw_attack_flash_only()
                return
    if heartwood_active or state == STATE_STORY:
        _draw_heartwood_fallback()
        _draw_attack_flash_only()
        return
    super._draw()

func _current_environment_id() -> String:
    if heartwood_active:
        return "heartwood_chamber"
    if state == STATE_STORY:
        if "MEMORY" in story_screen_title or "MEASURE" in story_screen_title:
            return "heartwood_memory"
        if "HEARTWOOD" in story_screen_title or "SEAL" in story_screen_title:
            return "heartwood_threshold"
        if "CUT" in story_screen_title:
            return "measured_cut"
    if state == STATE_HUB:
        return "wardens_rest"
    if state == STATE_RUN:
        match depth:
            1: return "gloamgrove"
            2: return "marrowroot"
            3: return "embermold"
    return ""

func _draw_heartwood_fallback() -> void:
    var base := Color("151a14") if not high_contrast else Color.BLACK
    draw_rect(Rect2(0, 0, 320, 180), base)
    draw_rect(Rect2(10, 24, 300, 144), Color("22281d"))
    draw_rect(Rect2(13, 27, 294, 138), Color("303825"))
    for x: int in range(18, 306, 22):
        var height := 18 + ((x * 11) % 48)
        draw_line(Vector2(x, 165), Vector2(x + ((x / 22) % 3 - 1) * 9, 165 - height), Color("667044"), 2.0)
    draw_circle(Vector2(160, 92), 38.0, Color(0.72, 0.62, 0.24, 0.08))
    draw_arc(Vector2(160, 92), 38.0, 0.0, TAU, 48, Color("887b42"), 2.0)

func _draw_attack_flash_only() -> void:
    if attack_flash > 0.0 and is_instance_valid(player) and not bool(SaveManager.settings.get("reduce_flashes", false)):
        var attack_center := player.position + player.facing.normalized() * float(selected_weapon.get("reach", 13.0))
        draw_circle(attack_center, float(selected_weapon.get("radius", 15.0)), Color(0.95, 0.82, 0.43, 0.20))
