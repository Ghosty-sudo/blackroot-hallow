# QA Matrix

## Automated / CI
- Expected project files exist.
- Save schema version is current and recoverable.
- Godot 4.7.2 imports the project headlessly.
- Main scene survives a short headless runtime smoke.
- Windows release preset exports successfully.
- Build artifact uploads successfully.

## Functional
- Fresh launch reaches title.
- Keyboard and controller can start and play.
- Weapon choice flows into Rootmark choice.
- Each weapon produces a noticeably different combat rhythm.
- Dodge grants brief invulnerability and respects cooldown.
- Boss charge has readable telegraph before damage.
- Fullscreen/windowed settings persist.
- Volume, shake, contrast, and flash settings persist.
- Pause/resume cannot duplicate enemies or progression.
- Death banks only intended currency and returns cleanly.
- Boss clear advances depth once.
- Final clear increments wins once.
- Closing/reopening preserves meta progression.
- A malformed primary save recovers from backup instead of hard failing.

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
