# Blackroot Hollow — Production Art Pipeline

## Goal
Art must be replaceable without rewriting gameplay. Code refers to semantic IDs (`warden`, `ember_stag`, `heartwood_chamber`) through `BlackrootArtCatalog`; filenames and import details stay inside the art layer.

Prototype `_draw()` art remains a deliberate fallback until a production asset exists. Dropping a valid asset into its catalog path automatically lets `BlackrootArtPresenter` take over that actor while preserving combat hitboxes, timing, AI, and save data.

## Source layout

```text
art/
  actors/
    warden/
      warden.png
      warden_frames.tres
    enemies/
    guardians/
  environments/
  portraits/
  ui/
```

Do not make gameplay scripts depend on source-editor filenames. If an asset is renamed, update `scripts/core/art_catalog.gd` only.

## Actor contract
Production actors may ship as either a static PNG or a Godot `SpriteFrames` resource. `SpriteFrames` is preferred once animation begins. Supported animation names are intentionally conventional: `idle`, `move`, `attack`, `dodge`, `hurt`, `death`, plus boss-specific actions. Missing animation names fall back to `idle` rather than breaking gameplay.

Use nearest-neighbor filtering. Keep the gameplay origin at the actor's feet/center consistently. Visual size does not define collision or attack reach; those remain gameplay data so an art revision cannot silently rebalance combat.

Recommended first-pass canvas targets at the 320×180 internal resolution:
- Warden: roughly 16×20 to 24×28 px visual footprint.
- Regular enemies: roughly 12×12 to 24×24 px.
- Guardians: roughly 28×28 to 48×48 px depending on silhouette.
- Heartwood Sentinel: may exceed guardian size, but its readable hurt/telegraph area must remain clear.

These are presentation targets, not hard import constraints.

## Environment contract
Environment IDs are route-owned. Current launch route expects:
`wardens_rest`, `gloamgrove`, `marrowroot`, `embermold`, `heartwood_threshold`, `heartwood_memory`, `heartwood_chamber`, and `measured_cut`.

Build backgrounds at the game's 320×180 base canvas or an integer multiple. Keep combat-critical floor readability separate from decorative foreground layers. Future parallax/foreground layers should be added to the art profile rather than hard-coded into encounter logic.

## Portrait/UI contract
Portraits and UI icons use semantic IDs as well. Dialogue code should request `mara_venn`, `old_fen`, `tallow`, or `rootvoice`; it should never load a portrait path directly.

## Safe replacement sequence
1. Create/import the asset under `art/`.
2. Keep or update its semantic path in `BlackrootArtCatalog`.
3. For animated actors, create the matching `SpriteFrames` resource and include `idle` at minimum.
4. Run art-framework smoke, story-route smoke, gameplay regression, and Windows/Web exports.
5. Human-check silhouette, telegraph readability, pivots, pixel scale, clipping, and UI contrast at 320×180 plus scaled desktop resolutions.
6. Only then remove obsolete prototype drawing for that asset. Until then, fallback rendering stays available.

## Story-production order
Prioritize art in the order the player encounters it: Warden's Rest/Warden → Gloamgrove/Briar Warden → Marrowroot/Marrow Bell → Embermold/Ember Stag → Heartwood threshold/memories → Heartwood Sentinel/chamber → Measured Cut/postgame. This keeps every art batch testable as a coherent player path.

## Non-negotiable rule
Art swaps must not change gameplay IDs, collision rules, save keys, story flags, or encounter progression. Presentation is replaceable; player progress and combat behavior are not.
