# Changelog

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
