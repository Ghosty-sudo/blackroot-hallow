# Blackroot Hollow

Compact commercial pixel action-RPG targeting Steam/Windows.

## Current maturity
**0.3.0 run-identity / player-path candidate**

Blackroot Hollow is being built release-first rather than as an open-ended prototype. The current repository contains a three-depth expedition loop, persistent progression/settings, three weapon rhythms, three Rootmark tradeoffs, two mid-run relic choices, three distinct guardians, dodge/iframes, save backup/recovery, accessibility toggles, keyboard/mouse + controller support, a Windows export pipeline, and a touch playtest layer for phones.

The visuals and procedural sound effects are still development assets. The game is **not store-ready**. The browser/mobile layer is a rapid-playtest convenience; the commercial release target remains Steam/Windows PC.

## Quality gate
Build state is tracked separately as:

**MACHINE-VALID → PLAYTEST-WORTHY → RELEASE-WORTHY**

Passing CI or exporting a build only establishes machine validity. Human handoff happens after a player-path QoL/polish audit clears obvious onboarding, control, navigation, feedback, persistence, presentation, and platform issues.

## Run identity in 0.3.0
The Rootmark establishes the run's initial bargain. After the first and second guardians, a Root Cache presents three relic choices drawn from a compact six-relic pool. Relics materially alter health, damage, dodge/movement, lifesteal, mitigation, or weapon reach. A full clear therefore carries weapon + Rootmark + two run relics rather than repeating the opening loadout unchanged.

Guardians now teach different movement reads:
- **Briar Warden** — readable line charge; step aside from its committed lane.
- **Marrow Bell** — telegraphed proximity pulse; leave the ring before detonation.
- **Ember Stag** — short chained dash tells; read two bursts instead of one.

Regular enemy weighting also changes by biome so later depths lean toward different pressure profiles without padding the roster with cosmetic copies.

## Player-path QoL
- Real pause menu with Resume, Restart Same Loadout, Settings, and Abandon.
- Same-loadout retry from death and replay from victory.
- Player-facing run results with depth, enemies defeated, Amber secured, and relic count.
- Permanent upgrade caps, escalating costs, visible ranks, and explicit effects.
- Separate Master and SFX volume controls.
- Save backup recovery notices and player-facing save-write errors.
- Automatic controller menu-focus recovery plus Esc/B back-navigation.
- Temporary combat/tutorial messages expire instead of lingering indefinitely.

## Browser playtest
Open `https://ghosty-sudo.github.io/blackroot-hallow/` in a current browser.

On a touchscreen phone, portrait mode shows a rotate prompt. In landscape, the Web canvas fills the usable safe area. Mobile controls recover from browser focus loss, directional dodge follows the active movement drag, and the combat overlay hides while paused so full pause/settings navigation remains readable.

## Automated QA
CI performs structural checks, Godot import/runtime checks, a scripted gameplay smoke, and a Windows release export. The gameplay smoke traverses onboarding, menus, weapon/Rootmark choice, pause/settings, combat, touch input, relic selection/effects, distinct guardian mapping, death/retry, biome progression, final victory, and key run-result state.

Automated QA catches obvious runtime/state regressions but does not replace human judgment about fun, feel, pacing, balance, readability, choice quality, or repetition.

## Controls
- Desktop move: WASD / Arrow keys / controller left stick
- Desktop attack: Space / left mouse / controller A
- Desktop dodge: Shift / controller B
- Desktop pause: Escape / controller Start
- Menu confirm: Enter / controller A / mouse
- Menu back: Escape / controller B
- Phone playtest move: drag inside MOVE
- Phone playtest attack: hold/tap ATTACK
- Phone playtest dodge: tap DODGE; active movement direction is respected
- Phone playtest pause: tap PAUSE, then use the full pause menu

## Core loop
Warden's Rest → choose weapon → bind Rootmark → clear depth → defeat guardian → choose relic → descend → repeat → bank Root Amber → buy capped permanent upgrades → descend again.

## Release target
A small premium Steam game for Windows x64. The scope target is a polished 2–4 hour first clear with replayability rather than a sprawling RPG.
