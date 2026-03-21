# MoodGarden UX Polish Design

## Problem

MVP is functionally complete but the experience falls short of the "quiet mirror" concept. Three core issues:

1. **Garden visuals** -- element placement feels random rather than structured, background and element art styles are inconsistent, animations are unnatural (pulsing scale changes)
2. **Mood selector** -- dot-to-arc interaction is unintuitive
3. **Post-recording experience** -- no sense of "something was added to my garden today"

## Design

### Phase 1: Visual Polish

#### A. Layered Placement Rules

Enforce strict layer discipline using existing PlacementZone infrastructure:

| Layer | Zone | Elements | Visual treatment |
|-------|------|----------|-----------------|
| Back (sky) | `.sky` | sunray, rainbow, raindrop | Large, low opacity, blends into background |
| Mid (hilltop) | `.hilltop` | flower, grass, vine, butterfly | Main focal elements, standard scale |
| Front (foreground/waterside) | `.foreground`, `.waterside` | moss, puddle, ripple, fallenLeaf, mushroom | Larger scale, higher opacity |
| Overlay (anywhere) | `.anywhere` | fog, wind | Spans all layers, semi-transparent |

Changes to PlacementRule:
- Reduce Y-axis scatter within each zone -- elements in the same layer should cluster at similar heights
- Add horizontal spread bias so elements don't stack vertically
- Existing DepthScale (Y-based scale/alpha/zPosition) remains, but becomes more effective with proper layer separation

#### B. Natural Animation System

**Principle: only movements that occur in nature are allowed.**

Remove all unnatural animations from all element types. Specifically:
- Remove all `pulseAlpha` calls (alpha oscillation) from every element
- Remove all scale oscillation (`SKAction.scale`) from every grounded element
- Remove any repeating grow/shrink cycles

**Rule: if an animation doesn't have a real-world physical cause, remove it.**

Introduce a global Wind system:

**WindState** (`Garden/WindState.swift`, new):
- Properties: `direction: CGFloat` (angle in radians), `strength: CGFloat` (0.0-1.0)
- Updated in `GardenScene.update(_ currentTime:)` (new override) using sine-based interpolation
- Cycle period: 8-12s, easing between calm (strength ~0.05) and gentle breeze (strength ~0.3). Never strong.

**Wind integration approach**: `GardenScene.update(_ currentTime:)` iterates over element child nodes and applies wind via named-node lookup and direct property manipulation. Elements are tagged with their `ElementType` in node name (already done: `"element_\(elementType)_\(seed)"`). No protocol changes needed -- wind behavior is driven by element type lookup in the scene's update loop.

Wind affects each element type differently:
- **Grass, flower, vine**: rotation toward wind direction, proportional to strength. Small random phase offset per element (derived from node position) so they don't move in perfect sync.
- **Fog**: slow drift in wind direction. Speed proportional to strength.
- **Raindrop**: slight angle offset from vertical, proportional to wind strength.
- **Butterfly**: irregular flight path biased by wind direction. Independent fluttering rhythm.
- **FallenLeaf**: drift along ground in wind direction. Occasional tumble.
- **Water (ripple, puddle)**: independent rhythm, unaffected by wind. Gentle concentric expansion.
- **Sunray, rainbow**: static, no animation. Light doesn't move with wind.
- **Mushroom, moss**: static. Grounded elements don't sway.

#### C. Visual Cohesion

- Apply season-based color tint to element sprites in `GardenScene.rebuildElements()` as a post-processing pass. After each element node is created and positioned, set `colorBlendFactor` and `color` based on the current season's `tintColor`. This applies uniformly and avoids inconsistency across 14 element files. Only applies to `SKSpriteNode` children (programmatic `SKShapeNode` elements are unaffected).
- DepthScale enhancement: reduce saturation for back-layer elements (aerial perspective)

### Phase 2: UI Interaction

#### D. Mood Selector Redesign

Replace dot-to-arc with bottom tap activation and horizontal row:

- **Default state**: small translucent pill/handle at bottom center. The garden fills the screen. (The handle fades to very low opacity after a few seconds of inactivity.)
- **Activation**: tap the bottom handle area. 7 mood icons slide up as a horizontal row, centered, with translucent background strip.
- **Selection**: tap an icon. Row slides back down. Transition begins.
- **Dismissal**: tap outside the row. Row slides back down. No recording.
- **Guard**: if `hasTodayEntry == true`, handle is hidden entirely.

Note: swipe-up is reserved for Archive access per the MVP spec ("Swipe up on garden view, or tap month name at top"). The mood selector uses a tap gesture on the bottom handle to avoid conflict.

#### E. Post-Recording Landing

Restructure `TransitionDirector.runTransition` to change when new elements are added:

**Current flow**: completion handler fires during fog phase, elements appear as fog dissipates.

**New flow**:
1. **Fog rises**: mood-tinted fog covers the scene (0.4s ease-in)
2. **Scene rebuilds behind fog**: all existing elements re-render at their current positions
3. **Fog clears**: fog fades out (0.6s ease-out)
4. **Completion fires after fog fully clears** (changed from current behavior)
5. **New element delayed entrance**: 0.5s after fog clears, the new element fades in starting from GrowthPhase.seed scale and growing to its current phase over 0.8s
6. **Subtle element-layer settle**: after new element appears, only `groundElementsLayer` and `aerialElementsLayer` ease from scale 1.0 to 0.97 and back to 1.0 over 1.2s. `backgroundLayer` and `seasonalLayer` are excluded to avoid background edge gaps.

No camera shake, no particle bursts, no congratulatory UI. Just "oh, it appeared."

## Scope

### In scope
- PlacementRule zone enforcement and Y-scatter reduction
- Wind animation system replacing pulse/scale animations
- Element sprite color tinting for seasonal cohesion (existing sprites only)
- Mood selector tap-to-expand redesign
- Post-recording transition restructuring

### Out of scope
- New sprite assets or replacing programmatic elements with image sprites
- Grid-based placement (day-to-cell mapping)
- Sound design
- Template-based or organic-growth placement (future consideration)
- Undo feature changes
- Archive access gesture changes

## Acceptance Criteria

1. Elements appear in visually coherent layers -- sky elements are in the sky, ground elements are on the ground
2. No element exhibits pulsing scale or alpha oscillation
3. Wind-influenced elements sway gently in a shared direction that changes over time
4. Water elements have independent, non-wind-based animation
5. Mood selector is hidden by default, activated by tapping bottom handle, shows horizontal row
6. After recording, new element appears with a distinct delayed fade-in after fog fully clears
7. Wind direction changes are visible across multiple element types simultaneously; no two adjacent elements animate in perfect sync
