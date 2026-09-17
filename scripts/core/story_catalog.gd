class_name BlackrootStoryCatalog
extends RefCounted

const FLAG_FIRST_DESCENT := "first_descent"
const FLAG_BRIAR_TRUTH := "briar_truth"
const FLAG_MARROW_TRUTH := "marrow_truth"
const FLAG_EMBER_TRUTH := "ember_truth"
const FLAG_HEARTWOOD_OPEN := "heartwood_open"
const FLAG_SENTINEL_DEFEATED := "sentinel_defeated"

static func hub_voice(flags: Dictionary, wins: int) -> Dictionary:
    if bool(flags.get(FLAG_SENTINEL_DEFEATED, false)):
        return {"speaker": "MARA VENN", "text": "The roots are quiet. Not dead. Quiet. Maybe that's what peace sounds like down there."}
    if bool(flags.get(FLAG_EMBER_TRUTH, false)):
        return {"speaker": "OLD FEN", "text": "We called the old fire a victory. Funny how often that word means nobody wrote down the cost."}
    if bool(flags.get(FLAG_MARROW_TRUTH, false)):
        return {"speaker": "TALLOW", "text": "Covenant. That's what the old carving said? Amber never sounded like a covenant on my anvil."}
    if bool(flags.get(FLAG_BRIAR_TRUTH, false)):
        return {"speaker": "OLD FEN", "text": "That badge wasn't grown there. I knew the man who wore it. Don't let anyone call him a beast to make this easier."}
    if bool(flags.get(FLAG_FIRST_DESCENT, false)) or wins > 0:
        return {"speaker": "MARA VENN", "text": "Bring back Amber. Bring yourself back first. The Rest needs both, no matter what Tallow says."}
    return {"speaker": "MARA VENN", "text": "Three descent crews stopped answering. You're the Warden we have left. Bind carefully and come back breathing."}

static func guardian_reveal(depth: int) -> Dictionary:
    match depth:
        1:
            return {
                "flag": FLAG_BRIAR_TRUTH,
                "speaker": "ROOTVOICE",
                "text": "Beneath the briars: a Warden's badge. The roots did not make the metal."
            }
        2:
            return {
                "flag": FLAG_MARROW_TRUTH,
                "speaker": "ROOTVOICE",
                "text": "The old wall names a covenant with the Heartwood. Not a mine. Not a conquest."
            }
        3:
            return {
                "flag": FLAG_EMBER_TRUTH,
                "speaker": "ROOTVOICE",
                "text": "Charred orders remain in the root: Warden's Rest lit the first fire when the Amber flow slowed."
            }
        _:
            return {}

static func rootmark_lore(mark_name: String) -> String:
    match mark_name:
        "Briar Oath":
            return "The bond opens both ways: your violence deepens, and so does what can reach you."
        "Fleet Root":
            return "The root turns endurance into motion. Nothing given. Only moved."
        "Blood Sap":
            return "What the blade takes can return to you, but the bond keeps its share first."
        _:
            return "Every gift from the Hollow has teeth."

static func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    var expected_flags := [FLAG_BRIAR_TRUTH, FLAG_MARROW_TRUTH, FLAG_EMBER_TRUTH]
    for depth: int in range(1, 4):
        var reveal := guardian_reveal(depth)
        if String(reveal.get("flag", "")) != expected_flags[depth - 1]:
            errors.append("guardian reveal flag mismatch at depth %d" % depth)
        if String(reveal.get("speaker", "")).is_empty() or String(reveal.get("text", "")).is_empty():
            errors.append("guardian reveal missing presentation at depth %d" % depth)
    for mark_name: String in ["Briar Oath", "Fleet Root", "Blood Sap"]:
        if rootmark_lore(mark_name).is_empty():
            errors.append("missing Rootmark lore: %s" % mark_name)
    return errors
