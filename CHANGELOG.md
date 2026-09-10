# Changelog

## 0.3.0 — Run Identity + Distinct Guardians
- Added two mid-run Root Cache choices so a successful expedition develops mechanically instead of remaining the same loadout from start to finish.
- Added six compact relics with distinct effects on health, damage, mobility/dodge recovery, lifesteal, mitigation, and attack reach.
- Added three different guardians instead of repeating Briar Warden at every depth: Briar Warden uses a readable line charge, Marrow Bell uses a telegraphed proximity pulse, and Ember Stag uses short chained dash tells.
- Weighted regular-enemy mixes differently by biome so each depth applies a different pressure profile without padding the roster with cosmetic variants.
- Added biome-specific floor markings and guardian guidance to strengthen depth identity.
- Added run relics to pause/results/HUD feedback and ensured same-loadout retry starts a fresh relic build.
- Surfaced save-write failures in player-facing hub/settings flows.
- Expanded automated gameplay QA to cover relic choices/effects, distinct guardian mapping, second-biome/final-biome transitions, clean retry state, and existing player-path QoL.
- Kept the scope intentionally compact: this is a depth/choice-quality pass, not a feature-count expansion.

## 0.2.4 — Player-Path QoL + Handoff Gate
- Replaced the pause text toggle with a real pause menu: Resume, Restart Same Loadout, Settings, and Abandon to Warden's Rest.
- Added same-loadout retry from death and replay from victory so testing and normal play do not require rebuilding the same choice path.
- Rewrote death/victory screens as player-facing result screens with depth, defeats, and Amber secured; removed developer-facing prototype residue.
- Added capped, escalating permanent upgrades with explicit effect/cost/rank feedback instead of endless flat-cost stat inflation.
- Added Master and SFX volume controls backed by a dedicated SFX audio bus.
- Added save-recovery/failure state reporting so backup recovery is visible instead of silent.
- Added automatic controller menu focus recovery and consistent Esc/B back-navigation across menu states.
- Fixed encounter/tutorial banner text so temporary guidance actually expires instead of lingering indefinitely.
- Hid the touch combat overlay while paused and restored the full menu layout for phone pause/settings flow.
- Expanded automated player-path QA for onboarding actions, pause/options, SFX settings, retry, run-result accounting, and removal of developer-facing victory copy.
- Adopted explicit MACHINE-VALID → PLAYTEST-WORTHY → RELEASE-WORTHY gating; green CI alone no longer triggers human handoff.

## 0.2.3 — Control Reliability + Combat Readability
- Made desktop dodge one activation per key/button press instead of allowing a held input to fire again as soon as cooldown expires.
- Added directional touch dodge so an active movement drag determines dodge direction instead of relying on stale facing.
- Added focus-loss touch cleanup to prevent stuck movement or attack state after browser/app interruption.
- Added clearer pressed/ready feedback to mobile controls and reduced their visual footprint again without shrinking hit targets.
- Compacted the mobile combat HUD further by hiding the subtitle during active encounters.
- Added regular-enemy hit flashes and damage health bars for clearer attack feedback.
- Added light enemy separation so regular enemies do not collapse into one unreadable stack.
- Updated the Web shell so landscape gameplay respects device safe-area insets around phone notches and browser edges.

## 0.2.2 — Mobile Landscape + Automated Gameplay QA
- Reworked the phone playtest presentation around landscape instead of allowing a squeezed portrait gameplay view.
- Added a mobile Web shell that fills the available browser viewport, blocks overscroll, respects safe-area insets, and shows a dedicated rotate prompt in portrait.
- Replaced oversized phone controls with smaller translucent visuals backed by larger invisible hit areas.
- Added scripted gameplay QA and hardened CI so generic Godot engine ERROR lines fail the build.

## 0.2.1 — Phone Playtest Controls
- Added a browser-only/mobile touch playtest adapter without changing the Steam/PC release target.
- Added multitouch drag movement plus dedicated Attack, Dodge, and Pause touch zones.

## 0.2.0 — Vertical Slice Candidate
- Added three selectable weapon archetypes, dodge/iframes, knockback, a telegraphed boss, biome identities, save recovery, accessibility toggles, and procedural placeholder SFX.

## 0.1.0 — Foundation
- Established title, hub, Rootmark, combat, boss, death, victory, and meta-progression loop.
