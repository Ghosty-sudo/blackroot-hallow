# Blackroot Hollow

Compact commercial pixel action-RPG targeting Steam/Windows.

## Current maturity
**0.2.0 vertical-slice candidate**

Blackroot Hollow is being built release-first rather than as an open-ended prototype. The current repository contains the complete basic expedition loop, persistent progression/settings, three weapon rhythms, three Rootmark tradeoffs, dodge/iframes, a telegraphed boss attack, save backup/recovery, accessibility toggles, keyboard/mouse + controller support, and a Windows export pipeline.

The visuals and procedural sound effects are still development assets. The game is **not store-ready**.

## Engine
- Godot 4.7.2 stable target
- GDScript
- 320×180 internal pixel presentation with integer-friendly scaling
- GL Compatibility renderer for broad Windows support

## Run locally
1. Install Godot 4.7.2.
2. Import `project.godot`.
3. Run the project.

## Controls
- Move: WASD / Arrow keys / controller left stick
- Attack: Space / left mouse / controller A
- Dodge: Shift / controller B
- Pause: Escape / controller Start

## Core loop
Warden's Rest → choose a weapon → choose a Rootmark → descend → clear encounters → defeat a guardian → bank Root Amber → buy permanent upgrades → descend again.

Rootmarks are the identity system: every one gives a strong advantage and a meaningful drawback.

## Release target
A small premium Steam game for Windows x64. The scope target is a polished 2–4 hour first clear with replayability rather than a sprawling RPG.
