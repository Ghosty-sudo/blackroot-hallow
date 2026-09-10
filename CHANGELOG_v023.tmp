# Changelog

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
- Replaced the oversized phone control presentation with smaller translucent visuals backed by larger invisible hit areas.
- Compacted the mobile combat HUD and hid desktop-only control instructions during touch gameplay.
- Added scripted gameplay QA that traverses title, hub, weapon selection, Rootmark selection, combat, guardian progression, death, and victory.
- Extended self-play QA to exercise actual ScreenTouch/ScreenDrag event paths for move, attack, dodge, and pause/resume.
- Fixed a mobile HUD style-initialization edge case found by the first automated gameplay pass.
- Hardened CI so generic Godot engine `ERROR:` lines fail the build instead of allowing a false-green result.

## 0.2.1 — Phone Playtest Controls
- Added a browser-only/mobile touch playtest adapter without changing the Steam/PC release target.
- Added multitouch drag movement plus dedicated Attack, Dodge, and Pause touch zones.
- Added visible phone control overlays that only appear during gameplay on touchscreen devices.
- Enabled touch-to-mouse emulation so existing menus remain tappable in mobile browsers.
- Kept keyboard/mouse and controller behavior intact for desktop testing.
- Bumped the Windows package version to 0.2.1 while retaining the same vertical-slice content scope.

## 0.2.0 — Vertical Slice Candidate
- Added three selectable weapon archetypes with different reach, damage, speed, and knockback.
- Added dodge movement, cooldown, and invulnerability frames.
- Added player/enemy knockback and stronger hit feedback.
- Replaced prototype boss behavior with a telegraphed Briar Warden charge.
- Added biome identities for Gloamgrove, Marrowroot, and Embermold.
- Added first-run tutorial messaging.
- Added save schema v2 with backup/recovery and migration behavior.
- Added Reduce Flashes setting alongside volume/fullscreen/shake/contrast.
- Added procedural placeholder SFX so combat/UI feedback can be tested before final audio exists.
- Expanded CI to include a short runtime smoke before Windows export.
- Added art-direction documentation and expanded QA/release blockers.

## 0.1.0 — Foundation
- Established title, hub, Rootmark, combat, boss, death, victory, and meta-progression loop.
- Added persistent settings/save data, controller basics, Windows export preset, and release documentation.
