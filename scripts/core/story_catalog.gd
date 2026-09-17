class_name BlackrootStoryCatalog
extends RefCounted

const FLAG_FIRST_DESCENT := "first_descent"
const FLAG_BRIAR_TRUTH := "briar_truth"
const FLAG_MARROW_TRUTH := "marrow_truth"
const FLAG_EMBER_TRUTH := "ember_truth"
const FLAG_HEARTWOOD_OPEN := "heartwood_open"
const FLAG_SENTINEL_DEFEATED := "sentinel_defeated"
const FLAG_MEASURED_CUT := "measured_cut"
const FLAG_TAKE_THE_ROOT := "take_the_root"

const REQUIRED_STORY_FLAGS := [
    FLAG_FIRST_DESCENT,
    FLAG_BRIAR_TRUTH,
    FLAG_MARROW_TRUTH,
    FLAG_EMBER_TRUTH,
    FLAG_HEARTWOOD_OPEN,
    FLAG_SENTINEL_DEFEATED,
    FLAG_MEASURED_CUT
]

static func hub_voice(flags: Dictionary, wins: int) -> Dictionary:
    if bool(flags.get(FLAG_MEASURED_CUT, false)):
        return {"speaker": "MARA VENN", "text": "No victory speech. We have ration tables to rewrite. Turns out saving a town creates paperwork."}
    if bool(flags.get(FLAG_SENTINEL_DEFEATED, false)):
        return {"speaker": "MARA VENN", "text": "You reached the first seal. Whatever waits behind it, we stop pretending the old answer is the only one."}
    if bool(flags.get(FLAG_HEARTWOOD_OPEN, false)):
        return {"speaker": "MARA VENN", "text": "Go down. This time, don't bring me the answer I want. Bring me the true one."}
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
                "text": "YOU CUT THE SHAPE THAT STOOD FOR YOU.",
                "discovery": "WARDEN BADGE — ARLEN ROOK"
            }
        2:
            return {
                "flag": FLAG_MARROW_TRUTH,
                "speaker": "ROOTVOICE",
                "text": "YOU NAMED THE GIFT ORE. THE NAME DID NOT CHANGE THE GIFT.",
                "discovery": "WHAT IS BORROWED RETURNS. WHAT IS TAKEN IS COUNTED."
            }
        3:
            return {
                "flag": FLAG_EMBER_TRUTH,
                "speaker": "ROOTVOICE",
                "text": "WE CLOSED THE WOUND. YOU CALLED THE CLOSING WAR.",
                "discovery": "KEEPER AUTHORIZATION — CONTROLLED BURN — RESTORE AMBER FLOW"
            }
        _:
            return {}

static func rootmark_lore(mark_name: String) -> String:
    match mark_name:
        "Briar Oath":
            return "The bond opens both ways. Your violence deepens. So does what can reach you."
        "Fleet Root":
            return "The root turns endurance into motion. Nothing given. Only moved."
        "Blood Sap":
            return "What the blade takes can return to you. The bond keeps its share first."
        _:
            return "Every gift from the Hollow has teeth."

static func heartwood_entry() -> Array[Dictionary]:
    return [
        {"speaker": "ROOTVOICE", "text": "You carry the old opening. That is why you hear me."},
        {"speaker": "ROOTVOICE", "text": "Your marks were cut from a promise. Each return taught the promise your shape."},
        {"speaker": "ROOTVOICE", "text": "You are not chosen. You are understood."}
    ]

static func heartwood_memories() -> Array[Dictionary]:
    return [
        {"id": "gift", "text": "WE HAD WATER. YOU HAD WINTER. WE MOVED LIFE."},
        {"id": "measure", "text": "WHAT WAS BORROWED RETURNED. PAIN WAS SHARED BY CONSENT."},
        {"id": "extraction", "text": "NEED LEARNED HUNGER. HUNGER KEPT NEED'S NAME."}
    ]

static func sentinel_lines() -> Dictionary:
    return {
        "intro": "WARDEN. YOU ARRIVE ARMED AT A DOOR YOUR KIND ONCE ENTERED UNARMED.",
        "phase_1": "BRIAR TAUGHT COMMITMENT.",
        "phase_2": "MARROW TAUGHT THE COST OF REMEMBERING.",
        "phase_3": "EMBER TAUGHT FLIGHT.",
        "final_phase": "NOW SHOW ME WHAT YOU LEARNED THAT THEY COULD NOT.",
        "defeat": "STRENGTH PROVES ONLY THAT YOU MAY ENTER. CHOICE PROVES WHAT ENTERED."
    }

static func heartwood_confrontation() -> Array[Dictionary]:
    return [
        {"speaker": "ROOTVOICE", "text": "I REMEMBER YOUR KIND AS ONE WOUND. YOU HAVE TAUGHT ME THAT MEMORY CAN LIE BY BEING INCOMPLETE."},
        {"speaker": "ROOTVOICE", "text": "LEAVE. TAKE YOUR MARKS. TAKE YOUR DEAD. TAKE YOUR HUNGER ABOVE. I WILL CLOSE EVERY PATH."},
        {"speaker": "MARA VENN", "text": "I found the old burn shafts. One order and I can bring half the lower Rest down on that chamber. I won't give it unless you ask."},
        {"speaker": "ROOTVOICE", "text": "FIRE WAITS IN HER MOUTH AGAIN."},
        {"speaker": "MARA VENN", "text": "And roots are under every house I have sworn to protect. We're both armed. That's the problem."}
    ]

static func measured_cut_lines() -> Array[Dictionary]:
    return [
        {"speaker": "ROOTVOICE", "text": "YOU CUT ME."},
        {"speaker": "ROOTVOICE", "text": "...NO. YOU CUT THE TAKING."},
        {"speaker": "ROOTVOICE", "text": "YOU LEAVE A PATH."},
        {"speaker": "ROOTVOICE", "text": "MEASURED."}
    ]

static func ending_epilogue() -> Array[Dictionary]:
    return [
        {"speaker": "MARA VENN", "text": "Open the Keeper archive. All of it. If my chair inherited the lie, my chair can publish it."},
        {"speaker": "OLD FEN", "text": "He wasn't a beast. Wasn't a saint either. He was a Warden. That's enough."},
        {"speaker": "TALLOW", "text": "Sustainable supply. Terrible for business. Excellent for sleeping."},
        {"speaker": "MARA VENN", "text": "Will it hold?"},
        {"speaker": "OLD FEN", "text": "Nothing holds forever."},
        {"speaker": "TALLOW", "text": "Helpful."},
        {"speaker": "MARA VENN", "text": "Then we measure again tomorrow."},
        {"speaker": "ROOTVOICE", "text": "RETURN, WARDEN. NOT TO TAKE. TO BE KNOWN."}
    ]

static func return_line_pool(flags: Dictionary) -> Array[Dictionary]:
    if bool(flags.get(FLAG_HEARTWOOD_OPEN, false)):
        return [
            {"speaker": "ROOTVOICE", "text": "YOU KNOW THE ROAD NOW."},
            {"speaker": "ROOTVOICE", "text": "RETURN IS DIFFERENT WHEN BOTH SIDES EXPECT IT."},
            {"speaker": "MARA VENN", "text": "You came back. Mission report starts after breathing."}
        ]
    if bool(flags.get(FLAG_MARROW_TRUTH, false)):
        return [
            {"speaker": "ROOTVOICE", "text": "YOU RETURN WITH LESS TAKEN."},
            {"speaker": "ROOTVOICE", "text": "PAIN IS NOT PROOF. LEARN ANYWAY."},
            {"speaker": "OLD FEN", "text": "Losing a fight teaches plenty. Staying dead teaches less."}
        ]
    return [
        {"speaker": "MARA VENN", "text": "Sit down before you fall down. The Hollow can wait thirty seconds."},
        {"speaker": "OLD FEN", "text": "Root-dragged? Means the mark found a road home."},
        {"speaker": "TALLOW", "text": "You lost Amber. I kept the anvil. Between us, we'll recover."}
    ]

static func postgame_voice_pool() -> Array[Dictionary]:
    return [
        {"speaker": "MARA VENN", "text": "Patrol, not conquest. Words matter because orders become habits."},
        {"speaker": "OLD FEN", "text": "New Wardens start with history before weapons now. Should've tried that sooner."},
        {"speaker": "TALLOW", "text": "Natural Amber grows slower. So do I. We're adapting."},
        {"speaker": "ROOTVOICE", "text": "MEASURE IS A VERB."}
    ]

static func next_required_flag(flags: Dictionary) -> String:
    for flag: String in REQUIRED_STORY_FLAGS:
        if not bool(flags.get(flag, false)):
            return flag
    return ""

static func story_complete(flags: Dictionary) -> bool:
    return next_required_flag(flags).is_empty()

static func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    var expected_flags := [FLAG_BRIAR_TRUTH, FLAG_MARROW_TRUTH, FLAG_EMBER_TRUTH]
    for depth: int in range(1, 4):
        var reveal := guardian_reveal(depth)
        if String(reveal.get("flag", "")) != expected_flags[depth - 1]:
            errors.append("guardian reveal flag mismatch at depth %d" % depth)
        if String(reveal.get("speaker", "")).is_empty() or String(reveal.get("text", "")).is_empty():
            errors.append("guardian reveal missing presentation at depth %d" % depth)
        if String(reveal.get("discovery", "")).is_empty():
            errors.append("guardian reveal missing discovery at depth %d" % depth)
    for mark_name: String in ["Briar Oath", "Fleet Root", "Blood Sap"]:
        if rootmark_lore(mark_name).is_empty():
            errors.append("missing Rootmark lore: %s" % mark_name)
    if heartwood_entry().size() < 3:
        errors.append("Heartwood entry sequence incomplete")
    if heartwood_memories().size() != 3:
        errors.append("Heartwood memory sequence must contain three core tableaux")
    var sentinel := sentinel_lines()
    for key: String in ["intro", "phase_1", "phase_2", "phase_3", "final_phase", "defeat"]:
        if String(sentinel.get(key, "")).is_empty():
            errors.append("missing Sentinel line: %s" % key)
    if heartwood_confrontation().size() < 5:
        errors.append("Heartwood confrontation incomplete")
    if measured_cut_lines().size() < 4:
        errors.append("Measured Cut sequence incomplete")
    if ending_epilogue().size() < 8:
        errors.append("ending epilogue incomplete")
    var completion_flags := {}
    for flag: String in REQUIRED_STORY_FLAGS:
        completion_flags[flag] = true
    if not story_complete(completion_flags):
        errors.append("required story flag chain cannot complete")
    return errors
