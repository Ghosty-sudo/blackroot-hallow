# QA Matrix

## Automated / CI
- Expected project files exist.
- Save schema version is current and recoverable.
- Godot 4.7.2 imports the project headlessly without engine/script/resource errors.
- Main scene survives a short headless runtime smoke.
- Scripted gameplay smoke traverses title, hub, weapon choice, Rootmark choice, combat, guardian progression, death, and victory.
- Phone-style ScreenTouch/ScreenDrag paths verify movement, attack, directional dodge, pause/resume, and touch cleanup.
- Desktop dodge cannot auto-repeat from one held input after cooldown.
- Enemy damage feedback and overlap separation are exercised.
- Windows release preset exports successfully.
- Web release preset exports and the mobile shell patch is applied.
- Build artifacts upload successfully.

## Functional
- Fresh launch reaches title.
- Keyboard and controller can start and play.
- Weapon choice flows into Rootmark choice.
- Each weapon produces a noticeably different combat rhythm.
- Dodge grants brief invulnerability and respects cooldown.
- One desktop dodge press cannot silently become repeated dodges when held.
- Mobile dodge follows the active movement drag direction.
- Losing browser/app focus clears held touch movement and attack state.
- Regular enemies separate enough to remain readable rather than stacking perfectly.
- Damaged enemies give visible hit feedback and remaining-health feedback.
- Boss charge has readable telegraph before damage.
- Fullscreen/windowed settings persist.
- Volume, shake, contrast, and flash settings persist.
- Pause/resume cannot duplicate enemies or progression.
- Death banks only intended currency and returns cleanly.
- Boss clear advances depth once.
- Final clear increments wins once.
- Closing/reopening preserves meta progression.
- A malformed primary save recovers from backup instead of hard failing.

## Mobile browser playtest
- Portrait displays the rotate prompt rather than squeezed gameplay.
- Landscape canvas uses the available safe area and avoids the notch/browser insets.
- Touch controls remain reachable without covering critical combat information.
- Move + Attack multitouch works.
- Move + Dodge multitouch uses the intended direction.
- App switch / browser focus loss does not leave movement or attack stuck.
- Pause button changes to Resume while paused and recovers cleanly.

## Human release sessions
- First 5 minutes: onboarding and comprehension.
- 30 minutes: pacing, readability, build choice.
- Full first clear.
- 2-hour stress session.
- Fresh install.
- Existing-save upgrade from schema v1.
- 720p / 1080p / 1440p / 4K.
- 16:9, 16:10, and ultrawide presentation.
- Keyboard/mouse only.
- Xbox-layout controller.
- Controller disconnect/reconnect.
- Low-volume and muted play.
