# Changelog

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
- Expanded automated gameplay QA for directional touch dodge, stuck-touch cleanup, desktop dodge repeat prevention, enemy hit feedback, and enemy separation.

## 0.2.2 — Mobile Landscape + Automated Gameplay QA
- Reworked the phone playtest presentation around landscape instead of allowing a squeezed portrait gameplay view.
- Added a mobile Web shell that fills the available browser viewport, blocks overscroll, respects safe-area insets, and shows a dedicated rotate prompt in portrait.
- Replaced oversized phone controls with smaller translucent visuals backed by larger invisible hit areas.
- Compacted the mobile combat HUD and hid desktop-only control instructions during touch gameplay.
- Added scripted gameplay QA for title, hub, weapon/Rootmark selection, combat, guardian progression, death, and victory.
- Extended self-play QA to exercise actual ScreenTouch/ScreenDrag event paths.
- Hardened CI so generic Godot engine ERROR lines fail the build.

## 0.2.1 — Phone Playtest Controls
- Added a browser-only/mobile touch playtest adapter without changing the Steam/PC release target.
- Added multitouch drag movement plus dedicated Attack, Dodge, and Pause touch zones.
- Enabled touch-to-mouse emulation so existing menus remain tappable in mobile browsers.

## 0.2.0 — Vertical Slice Candidate
- Added three selectable weapon archetypes with different reach, damage, speed, and knockback.
- Added dodge movement, cooldown, and invulnerability frames.
- Added player/enemy knockback and stronger hit feedback.
- Replaced prototype boss behavior with a telegraphed Briar Warden charge.
- Added biome identities for Gloamgrove, Marrowroot, and Embermold.
- Added first-run tutorial messaging, save backup/recovery, accessibility toggles, and procedural placeholder SFX.

## 0.1.0 — Foundation
- Established title, hub, Rootmark, combat, boss, death, victory, and meta-progression loop.
- Added persistent settings/save data, controller basics, Windows export preset, and release documentation.
