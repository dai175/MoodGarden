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

Remove:
- `pulseAlpha` on flowers, moss, and other static elements (plants don't pulse)
- Scale oscillation on any grounded element

Introduce a global Wind system:
- `WindState` struct: direction (angle), strength (0.0-1.0), updated on a slow cycle (8-12s period, sine-based)
- Wind affects each element type differently:
  - **Grass, flower, vine**: rotation toward wind direction, proportional to strength. Small random phase offset per element so they don't move in perfect sync.
  - **Fog**: slow drift in wind direction. Speed proportional to strength.
  - **Raindrop**: slight angle offset from vertical, proportional to wind strength.
  - **Butterfly**: irregular flight path biased by wind direction. Independent fluttering rhythm.
  - **FallenLeaf**: drift along ground in wind direction. Occasional tumble.
  - **Water (ripple, puddle)**: independent rhythm, unaffected by wind. Gentle concentric expansion.
  - **Sunray, rainbow**: static, no animation. Light doesn't move with wind.
  - **Mushroom, moss**: static. Grounded elements don't sway.
- Wind cycle: ease between calm (strength ~0.05) and gentle breeze (strength ~0.3). Never strong. The garden is always quiet.

#### C. Visual Cohesion

- Apply season-based color tint to element sprites via `colorBlendFactor` so they match the background palette
- DepthScale enhancement: reduce saturation for back-layer elements (aerial perspective)
- Ensure all sprite assets share consistent art direction (warm, soft, painterly)

### Phase 2: UI Interaction

#### D. Mood Selector Redesign

Replace dot-to-arc with swipe-up gesture:

- **Default state**: nothing visible. The garden is the entire screen. (Tiny translucent handle line at bottom edge, fades out after first few uses.)
- **Activation**: swipe up from bottom edge of screen. 7 mood icons slide in as a horizontal row, centered, with translucent background strip.
- **Selection**: tap an icon. Row slides back down. Transition begins.
- **Dismissal**: swipe down or tap outside. Row slides back down. No recording.
- **Guard**: if `hasTodayEntry == true`, swipe-up does nothing.

This aligns with the spec's "horizontal row" design and the concept's "viewing time > operating time" -- the selector is invisible until deliberately summoned.

#### E. Post-Recording Landing

Improve the "fog clearing" transition to give a clear sense of arrival:

1. **Fog rises** (existing): mood-tinted fog covers the scene (0.4s ease-in)
2. **Scene rebuilds behind fog**: all existing elements re-render at their current positions
3. **Fog clears** (existing): fog fades out (0.6s ease-out)
4. **New element delayed entrance** (new): the newly added element fades in 0.5s after fog clears, starting from GrowthPhase.seed scale and growing to its current phase over 0.8s
5. **Subtle scene settle** (new): after new element appears, scene scale eases from 1.0 to 0.97 and back to 1.0 over 1.2s -- a gentle "breathing" that frames the whole garden with the new addition

No camera shake, no particle bursts, no congratulatory UI. Just "oh, it appeared."

## Scope

### In scope
- PlacementRule zone enforcement and Y-scatter reduction
- Wind animation system replacing pulse/scale animations
- Element sprite color tinting for seasonal cohesion
- Mood selector swipe-up redesign
- Post-recording transition enhancement

### Out of scope
- New sprite assets or art direction changes
- Grid-based placement (day-to-cell mapping)
- Sound design
- Template-based or organic-growth placement (future consideration)
- Undo feature changes

## Acceptance Criteria

1. Elements appear in visually coherent layers -- sky elements are in the sky, ground elements are on the ground
2. No element exhibits pulsing scale or alpha oscillation
3. Wind-influenced elements sway gently in a shared direction that changes over time
4. Water elements have independent, non-wind-based animation
5. Mood selector is invisible by default, activated by swipe-up, shows horizontal row
6. After recording, new element appears with a distinct delayed fade-in after fog clears
7. Garden feels like a quiet, living landscape rather than a collection of animated sprites
