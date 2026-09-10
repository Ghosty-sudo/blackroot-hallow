# Blackroot Hollow

Working title for a compact commercial pixel action-RPG targeting Steam/Windows.

## Current maturity
**Prototype / vertical-slice foundation — 0.1.0**

This repository seed intentionally starts with release-minded systems instead of a throwaway demo: persistent progression, persistent settings, keyboard/mouse and controller input, fullscreen toggle, pausing, a complete run loop, death handling, a boss gate, and a Windows export preset.

The current art is programmer pixel-art and the current campaign is a systems slice. It is not store-ready.

## Engine
- Godot 4.7.2 stable target
- GDScript
- 320×180 internal presentation, integer-friendly scaling
- GL Compatibility renderer for broad PC support

## Run locally
1. Install Godot 4.7.2.
2. Import `project.godot`.
3. Run the project.

## Controls
- Move: WASD / Arrow keys / left stick
- Attack: Space / left mouse / controller A
- Pause: Escape / controller Start

## Core loop
Warden's Rest → choose a Rootmark → descend through encounters → defeat Heartwood guardians → bank Root Amber → buy permanent upgrades → descend again.

Rootmarks are the identity system: each gives a strong advantage and a meaningful drawback.

## Release target
Small premium Steam game, initially Windows x64. Target scope is a polished 2–4 hour first clear with replayability rather than a large open-world RPG.
