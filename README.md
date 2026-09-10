# Blackroot Hollow

Compact commercial pixel action-RPG targeting Steam/Windows.

## Current maturity
**0.2.4 player-path polish candidate**

Blackroot Hollow is being built release-first rather than as an open-ended prototype. The current repository contains the complete basic expedition loop, persistent progression/settings, three weapon rhythms, three Rootmark tradeoffs, dodge/iframes, a telegraphed boss attack, save backup/recovery, accessibility toggles, keyboard/mouse + controller support, a Windows export pipeline, and a touch playtest layer for phones.

The visuals and procedural sound effects are still development assets. The game is **not store-ready**. The browser/mobile layer is a rapid-playtest convenience; the commercial release target remains Steam/Windows PC.

## Quality gate
Build state is tracked separately as:

**MACHINE-VALID → PLAYTEST-WORTHY → RELEASE-WORTHY**

Passing CI or exporting a build only establishes machine validity. Human handoff happens after a player-path QoL/polish audit clears obvious onboarding, control, navigation, feedback, persistence, presentation, and platform issues.

## Engine
- Godot 4.7.2 stable target
- GDScript
- 320×180 internal pixel presentation with integer-friendly scaling
- GL Compatibility renderer for broad Windows support

## Browser playtest
Open `https://ghosty-sudo.github.io/blackroot-hallow/` in a current browser.

On a touchscreen phone, portrait mode shows a rotate prompt. In landscape, the Web canvas fills the usable safe area instead of extending under the notch/browser insets. The combat HUD is compact, desktop-only instructions are hidden, and visible controls stay small while retaining generous touch targets.

Mobile controls recover cleanly if the browser loses focus and directional dodge follows the active movement drag. While paused, the touch combat overlay hides so the full pause/settings menu remains readable.

## Player-path QoL in 0.2.4
- Real pause menu with Resume, Restart Same Loadout, Settings, and Abandon.
- Same-loadout retry from death and replay from victory.
- Player-facing death/victory results with run depth, enemies defeated, and Amber secured.
- Permanent upgrade caps, escalating costs, visible ranks, and explicit effects.
- Separate Master and SFX volume controls.
- Save backup recovery notices instead of silent recovery.
- Automatic controller menu-focus recovery plus Esc/B menu back-navigation.
- Temporary combat/tutorial messages expire instead of lingering indefinitely.

## Automated QA
CI performs structural checks, Godot import/runtime checks, a scripted gameplay smoke, and a Windows release export. The gameplay smoke traverses onboarding, menus, weapon/Rootmark choice, pause/settings, combat, touch input, directional dodge, interruption cleanup, enemy readability, death/retry, guardian progression, victory/replay, and key run-result accounting.

Automated QA catches obvious runtime/state regressions but does not replace human judgment about fun, feel, pacing, balance, readability, or repetition.

## Run locally
1. Install Godot 4.7.2.
2. Import `project.godot`.
3. Run the project.

## Controls
- Desktop move: WASD / Arrow keys / controller left stick
- Desktop attack: Space / left mouse / controller A
- Desktop dodge: Shift / controller B (one dodge per press)
- Desktop pause: Escape / controller Start
- Menu confirm: Enter / controller A / mouse
- Menu back: Escape / controller B
- Phone playtest move: drag inside the MOVE area
- Phone playtest attack: hold/tap ATTACK
- Phone playtest dodge: tap DODGE; active move direction is respected
- Phone playtest pause: tap PAUSE, then use the full pause menu

## Core loop
Warden's Rest → choose a weapon → choose a Rootmark → descend → clear encounters → defeat a guardian → bank Root Amber → buy capped permanent upgrades → descend again.

Rootmarks are the identity system: every one gives a strong advantage and a meaningful drawback.

## Release target
A small premium Steam game for Windows x64. The scope target is a polished 2–4 hour first clear with replayability rather than a sprawling RPG.
