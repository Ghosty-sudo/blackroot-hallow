# Blackroot Hollow

Compact commercial pixel action-RPG targeting Steam/Windows.

## Current maturity
**0.2.2 vertical-slice mobile-playtest candidate**

Blackroot Hollow is being built release-first rather than as an open-ended prototype. The current repository contains the complete basic expedition loop, persistent progression/settings, three weapon rhythms, three Rootmark tradeoffs, dodge/iframes, a telegraphed boss attack, save backup/recovery, accessibility toggles, keyboard/mouse + controller support, a Windows export pipeline, and a touch playtest layer for phones.

The visuals and procedural sound effects are still development assets. The game is **not store-ready**. Phone controls are a rapid-playtest convenience; the commercial release target remains Steam/Windows PC.

## Engine
- Godot 4.7.2 stable target
- GDScript
- 320×180 internal pixel presentation with integer-friendly scaling
- GL Compatibility renderer for broad Windows support

## Browser playtest
Open `https://ghosty-sudo.github.io/blackroot-hallow/` in a current browser.

On a touchscreen phone, portrait mode now shows a rotate prompt instead of squeezing the game into a tall browser viewport. Rotate to landscape for combat. The Web shell fills the available browser viewport, the combat HUD compacts, desktop-only instructions disappear, and touch controls use smaller visuals with larger invisible hit areas.

## Automated QA
CI performs structural checks, Godot import/runtime checks, a scripted gameplay smoke, and a Windows release export. The gameplay smoke traverses menus and core state changes and exercises real ScreenTouch/ScreenDrag event paths for movement, attack, dodge, and pause/resume. Automated QA catches obvious runtime/state regressions but does not replace human feel/readability/balance testing.

## Run locally
1. Install Godot 4.7.2.
2. Import `project.godot`.
3. Run the project.

## Controls
- Desktop move: WASD / Arrow keys / controller left stick
- Desktop attack: Space / left mouse / controller A
- Desktop dodge: Shift / controller B
- Desktop pause: Escape / controller Start
- Phone playtest move: drag inside the MOVE area
- Phone playtest attack: hold/tap ATTACK
- Phone playtest dodge: tap DODGE
- Phone playtest pause/resume: tap PAUSE/RESUME

## Core loop
Warden's Rest → choose a weapon → choose a Rootmark → descend → clear encounters → defeat a guardian → bank Root Amber → buy permanent upgrades → descend again.

Rootmarks are the identity system: every one gives a strong advantage and a meaningful drawback.

## Release target
A small premium Steam game for Windows x64. The scope target is a polished 2–4 hour first clear with replayability rather than a sprawling RPG.
