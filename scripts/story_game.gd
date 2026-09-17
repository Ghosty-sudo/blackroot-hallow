extends "res://scripts/game.gd"

func current_story_stage() -> Dictionary:
    return BlackrootStoryRoute.next_unfinished(SaveManager.story_flags())

func _show_hub() -> void:
    super._show_hub()
    var voice := BlackrootStoryCatalog.hub_voice(SaveManager.story_flags(), int(SaveManager.save_data.get("wins", 0)))
    var speaker := String(voice.get("speaker", ""))
    var text := String(voice.get("text", ""))
    if not speaker.is_empty() and not text.is_empty():
        info_label.text += "\n%s: %s" % [speaker, text]

func _show_marks() -> void:
    super._show_marks()
    subtitle_label.text = "Every gift from the Hollow moves a cost somewhere else."
    footer_label.text = "The curse is the price of the blessing, not flavor text."

func _start_run(mark: Dictionary) -> void:
    var tutorial_was_seen := bool(SaveManager.save_data.get("tutorial_seen", false))
    if not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_FIRST_DESCENT, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_FIRST_DESCENT)
    super._start_run(mark)
    if tutorial_was_seen:
        message = BlackrootStoryCatalog.rootmark_lore(String(mark.get("name", "")))
        banner_timer = 4.2
        _refresh_info()

func _advance_encounter() -> void:
    var cleared_guardian := wave > 0 and wave % 4 == 0
    var cleared_depth := depth
    super._advance_encounter()
    if not cleared_guardian:
        return
    var reveal := BlackrootStoryCatalog.guardian_reveal(cleared_depth)
    if reveal.is_empty():
        return
    var flag := String(reveal.get("flag", ""))
    var already_seen := bool(SaveManager.story_flags().get(flag, false))
    if not already_seen:
        SaveManager.set_story_flag(flag)
        var speaker := String(reveal.get("speaker", "ROOTVOICE"))
        var text := String(reveal.get("text", ""))
        if state == STATE_RELICS:
            info_label.text = "%s: %s\n\n%s" % [speaker, text, info_label.text]
        elif state == STATE_VICTORY:
            subtitle_label.text = "The third guardian falls. Something deeper answers."
            info_label.text += "\n%s: %s\nA sealed way beneath Embermold stirs. The Heartwood is deeper than the old maps admit." % [speaker, text]
            footer_label.text = "The expedition is clear. The story is not."
    if cleared_depth == 3 and not bool(SaveManager.story_flags().get(BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN, false)):
        SaveManager.set_story_flag(BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN)

func _show_victory() -> void:
    super._show_victory()
    title_label.text = "THE THIRD SEAL BREAKS"
    subtitle_label.text = "Briar, bone, and ember fall quiet — but the Heartwood does not."
