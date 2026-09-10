# QA Matrix

## Automated / CI
- Expected project files exist; no staging/debug residue ships.
- Godot 4.7.2 imports and runs the main scene without parser/resource/engine errors.
- Scripted gameplay smoke covers title, hub, weapon, Rootmark, run, pause/settings, touch input, relic selection, biome guardians, death/retry, and victory.
- Windows release export and browser export/deploy complete successfully.
- Save backup/recovery and separate Master/SFX settings remain wired.

## Player-path machine checks
- Opening presents an obvious Begin action and concise objective.
- Hub exposes capped permanent upgrades with visible rank/effect/cost.
- Pause offers Resume, Restart, Settings, and Abandon.
- Controller menu focus is reacquired after dynamic menu transitions.
- Esc/B backs through normal menus without skipping required relic choices.
- Death offers immediate same-loadout retry and reports run result.
- Victory offers same-loadout replay and contains no developer-facing copy.
- Touch overlay hides while paused; landscape controls/safe areas remain reachable.
- Temporary tutorial/guardian messages expire.
- Save recovery/write failures can be surfaced to the player.

## Run-identity checks
- Weapon and Rootmark remain the pre-run identity choices.
- Depth 1 guardian is Briar Warden; Depth 2 is Marrow Bell; Depth 3 is Ember Stag.
- Guardian tells are visually distinct and precede their high-pressure attacks.
- Clearing depths 1 and 2 opens a three-option Root Cache before the next biome.
- Relic choices exclude already-bound relics and persist only for that expedition.
- Six initial relics alter different dimensions: HP, damage, mobility/dodge, lifesteal, mitigation, reach.
- Same-loadout retry clears run relics and restarts from Depth 1.
- Regular enemy weighting changes by depth rather than repeating one identical mix.

## Human playtest gate
Only ask for a meaningful human test after automated checks and a player-path polish audit pass. Human test should answer:
- Is combat fun and responsive?
- Do the three guardians feel fair and legible rather than merely different?
- Do the two relic choices noticeably change the run?
- Does one full expedition become repetitive before the final guardian?
- Does progression feel rewarding without making later runs trivial?
- Is any player-facing text/control/presentation confusing despite functioning?

## Release-level sessions still required
- First 5 minutes with no developer explanation.
- 30-minute pacing/build-choice session.
- Full clear and repeated clear.
- 2-hour stress session.
- Fresh install and existing-save migration/recovery.
- 720p / 1080p / 1440p / 4K / ultrawide.
- Keyboard/mouse and Xbox-layout controller including disconnect/reconnect.
- Low-volume/muted play and accessibility toggles.
- Clean Windows machine package test.
