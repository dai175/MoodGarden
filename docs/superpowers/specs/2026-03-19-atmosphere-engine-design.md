# Atmosphere Engine — Garden Rendering Redesign

## Context

The current garden implementation places one mood element per grid cell (7×5 grid), producing a layout that feels like "icons on a calendar" rather than a living landscape. The concept document describes a garden where moods become weather — accumulating into a cohesive emotional landscape over a month. This redesign transforms the rendering system from grid-based placement to an atmosphere-driven living garden.

### Design Principles (from concept doc)

1. **The garden does not judge** — All moods produce equally beautiful elements. No mood makes the garden "worse."
2. **Viewing time > Operating time** — Recording takes 5 seconds. The garden exists to be gazed at.
3. **Insights are self-discovered** — The landscape tells the story; the app never explains it.

### Scope

- `Garden/` layer: full redesign of rendering, placement, and element systems
- `MoodSelectorView`: recording flow and transition experience
- `GardenViewModel`: integration with AtmosphereEngine
- `GardenView`: connection to new GardenScene

Out of scope: Models, Services, Archive, Settings, Onboarding, Notifications.

### Background Asset Strategy

Background images are AI-generated (e.g., using image generation tools) before implementation begins. They are committed to `Resources/Backgrounds.xcassets` as static assets bundled with the app.

- **Who**: Developer generates images using AI tools (Midjourney, DALL-E, etc.)
- **When**: Before the BackgroundLayer implementation phase
- **Placeholder strategy**: Until final images are ready, use solid color gradients matching each season's palette (spring: green-pink, summer: deep green-gold, autumn: amber-brown, winter: blue-white). This allows all rendering code to be developed and tested independently of art assets.
- **Requirements**: Consistent art style across all 4 seasons. Same terrain composition (hill left, water center-right, open ground foreground). Dark green base palette (#0A1A12 to #0D2818).

---

## Architecture

### Data Flow

```
MoodEntry[] (SwiftData)
     ↓
GardenViewModel
     ↓ entries, season
AtmosphereEngine.analyze()
     ↓
AtmosphereState (value type)
├── moodRatios: [MoodType: Float]
├── dominantMood: MoodType
├── hueShift: Float            (color direction, not quality)
├── elementManifest: [ElementSpec]
└── growthStates: [UUID: GrowthPhase]
     ↓
GardenScene renders
```

Unidirectional: ViewModel → Engine → State → Scene. Engine is pure logic, no SpriteKit dependency.

### ElementSpec

The bridge between Engine output and Scene rendering:

```swift
struct ElementSpec: Equatable {
    let entryID: UUID          // source MoodEntry
    let elementType: ElementType   // .flower, .butterfly, .moss, etc.
    let seed: Int              // deterministic random for this element
    let phase: GrowthPhase     // .seed, .sprout, .bloom, .mature
    let zone: PlacementZone    // .hilltop, .waterside, .sky, .foreground, .anywhere
    let estimatedNodes: Int    // for budget tracking (typically 1-4)
}
```

### Layer Structure

```
GardenScene
├── z=0   BackgroundLayer (AI images, 3 sub-layers)
│         ├── skySprite      (opaque, full scene)
│         ├── hillsSprite    (bottom transparent)
│         └── groundSprite   (top transparent)
├── z=10  GroundElementsLayer (surface elements)
│         └── moss, flowers, grass, vines, puddles, fallen leaves
├── z=20  AerialElementsLayer (airborne elements)
│         └── butterflies, rain, fog, wind, sunrays, rainbow
├── z=30  SeasonalLayer (existing, extended)
│         └── cherry blossoms, fireflies, autumn leaves, snow
├── z=40  AtmosphereOverlay (global mood tint)
│         └── colorBlendFactor 10-15%, vignette
└── z=100 TransitionLayer (fog-clearing effect)
```

---

## AtmosphereEngine

### MoodPalette

Converts mood ratios into a subtle color direction for the garden. Critically, this does NOT judge — brightness is never affected by mood ratios.

- **hueShift**: Direction on color wheel. Happy-dominant → warm hues. Sad-dominant → cool hues. Angry-dominant → deep greens. All directions are equally beautiful.
- **brightness**: Determined by season and time of day only. Never by mood ratios.
- **Influence cap**: 10-15% maximum effect on background via `colorBlendFactor`. Individual elements dominate the garden's impression.

### MoodAtmosphere (Element Pool)

Each mood defines a pool of possible elements, not a single mapping. What appears is determined by multiple factors:

```
Selection factors:
1. seed (deterministic random)
2. season (spring → flowers more likely)
3. recent moods (sad → happy → rainbow possibility)
4. existing elements (avoid excessive duplication)
```

Per entry: 2-4 elements selected from the pool.

Element pools (all 7 moods):

| Mood | Base elements (1-2 selected) | Supplementary elements (0-2 selected) |
|------|------------------------------|--------------------------------------|
| peaceful | moss, still water | soft light, smooth pebbles, mushrooms |
| happy | flowers, warm light | butterflies, gentle breeze, birdsong shimmer |
| energetic | tall grass, flowing stream | sunrays, bright wind, wildflowers |
| anxious | fog patches, tangled vines | low clouds, dim pulse, cobwebs |
| sad | quiet rain, water ripples | puddles, mist, gray clouds |
| angry | strong wind, bent branches | rough waves, storm clouds, wind streaks |
| tired | fallen leaves, dim light | bare twigs, still air shimmer, mushrooms |

### Consecutive Mood Bonus

When the same mood appears on consecutive days, the garden deepens rather than darkens. Every mood's consecutive bonus increases richness, never negativity.

| Mood | 3-day consecutive effect |
|------|------------------------|
| peaceful | Moss spreads, a quiet garden pond forms |
| happy | Flower field emerges, more butterflies |
| energetic | Meadow expands, a stream begins flowing |
| anxious | Fog deepens into a fantastical dreamscape |
| sad | Water area widens into a serene lake |
| angry | Wind intensifies into a majestic storm vista |
| tired | Twilight deepens into a warm, peaceful dusk |

Density multiplier: 2 consecutive = 1.3×, 3 consecutive = 1.6×. Constrained by node budget.

Consecutive bonus is computed inside `AtmosphereEngine.analyze()` and reflected in `ElementSpec` counts within `elementManifest`. The density multiplier increases element count but PlacementRule ensures minimum spacing is maintained, and total estimated nodes stay within the 400 budget.

### GrowthManager

Elements grow over time, creating a reason to return (concept Section 6.2).

| Phase | Days since record | Scale | Alpha | Animation |
|-------|------------------|-------|-------|-----------|
| .seed | 0 | 0.3 | 0.4 | None |
| .sprout | 1 | 0.6 | 0.7 | Subtle |
| .bloom | 2 | 1.0 | 1.0 | Full |
| .mature | 3+ | 1.0 | 0.9 | Minimal |

Growth phase is computed from the entry's creation date vs. current date. Deterministic, no stored state needed.

### PlacementRule

Elements are placed in zones that correspond to the background terrain, not a grid.

| Zone | Background area | Suitable elements |
|------|----------------|-------------------|
| .hilltop | Left hill area | Flowers, grass, sunrays |
| .waterside | Center-right water | Moss, fog, puddles, ripples |
| .sky | Upper area | Butterflies, rain, wind, rainbow |
| .foreground | Bottom area | Fallen leaves, vines, ground moss |
| .anywhere | No constraint | Warm light, breeze |

Placement uses seed-based random positioning within zone bounds. Minimum distance between elements prevents overlap.

Background images share the same terrain composition across all seasons so zone coordinates are reusable.

Zone bounds (as ratios of sceneSize, origin at center):

| Zone | x range | y range |
|------|---------|---------|
| .sky | -0.5 to 0.5 | 0.15 to 0.5 |
| .hilltop | -0.5 to 0.0 | -0.05 to 0.15 |
| .waterside | 0.0 to 0.5 | -0.15 to 0.05 |
| .foreground | -0.5 to 0.5 | -0.5 to -0.15 |
| .anywhere | -0.5 to 0.5 | -0.5 to 0.5 |

These ratios are preliminary and will be tuned when background images are finalized. The ratios are defined in a single configuration struct (`ZoneLayout`) for easy adjustment.

---

## Performance

### Node Budget

Target: ≤ 400 nodes (below the 500 spec limit, with headroom).

Unmitigated worst case: 30 days × 4 elements × 3-4 nodes each = 360-480 nodes (exceeds budget). Mitigation strategies below bring this under 400.

Mitigation strategies:

1. **GrowthPhase LOD**: `.mature` elements use 1-2 nodes with minimal animation
2. **Recency LOD**: Last 7 days → full quality. 8-14 days → medium (reduced animation). 15+ days → low (static, single node)
3. **Budget enforcement**: `ElementManifest` generation estimates total node count. If exceeding 400, reduce supplementary elements while keeping base elements.

### Background Assets

| Layer | Format | Estimated size per file |
|-------|--------|----------------------|
| sky (opaque) | HEIC | 200-400 KB |
| hills (transparent) | Lossy PNG | 300-600 KB |
| ground (transparent) | Lossy PNG | 300-600 KB |

Total: 4 seasons × 3 layers × 2 resolutions (@2x, @3x) = 24 files. Estimated 6-13 MB total.

App Thinning ensures only the device's resolution is delivered. Well within the 200 MB Wi-Fi threshold.

---

## MoodSelector Redesign

### Recording Flow

Target: operation ≤ 3 seconds + transition 1.5-2.0 seconds = total ≤ 5 seconds (concept principle).

1. **Hint tap** → selector expands in arc layout (0.3s)
2. **Single tap** to confirm mood (no labels, no second tap)
3. **Transition** (1.5-2.0s):
   - Phase 1 — Stillness (0.3s): Existing animations slow down. No darkening.
   - Phase 2 — Fog rises (0.5s): Mood-tinted fog, soft focus.
   - Phase 3 — Fog clears (0.7-1.2s): New elements appear in `.seed` phase. Color temperature subtly adjusts.
4. **Undo** (3s window, once only): Small "undo" text appears briefly, fades naturally. Tapping reverses the recording:
   - New `.seed` elements fade out (0.3s)
   - Fog briefly returns and clears (0.5s), restoring previous state
   - GardenViewModel deletes the MoodEntry from SwiftData
   - AtmosphereEngine re-analyzes remaining entries → new AtmosphereState
   - GardenScene re-renders from updated state
   - After undo, the user can record again (selector reappears). This second recording is final — no undo is offered. This encourages intuitive, immediate selection (Principle 2) while allowing one chance to correct a genuine mis-tap.

### Adaptive Transition Duration

Transition shortens as the user gains familiarity. Record count is cumulative (all-time), stored in `AppState` via `@AppStorage`.

- Records 1-10: 2.0s (full experience)
- Records 11-30: 1.7s
- Records 31+: 1.5s (experienced user)

Phase 1 stays constant at 0.3s. Phase 2 and 3 shorten proportionally.

Note: `AppState` already uses `@AppStorage` for `hasCompletedOnboarding`. Adding a `totalRecordCount: Int` follows the same pattern and does not require Model changes.

### Selector Design

- Arc layout (not horizontal scroll)
- Abstract icons (existing MoodIcon reusable)
- No labels displayed
- No haptic feedback
- No bounce or spring animations
- easeInEaseOut only

---

## File Structure

### Unchanged

```
App/, Models/, Services/,
Views/ArchiveView.swift, Views/ArchiveDetailView.swift,
Views/OnboardingView.swift, Views/SettingsView.swift, Views/RootView.swift,
Views/Theme/, Views/Components/,
ViewModels/ArchiveViewModel.swift, ViewModels/SettingsViewModel.swift
```

### Modified

```
ViewModels/GardenViewModel.swift    — AtmosphereEngine integration, growth calculation
Views/GardenView.swift              — New GardenScene connection
Views/MoodSelectorView.swift        — Single-tap, arc layout, undo, adaptive transition
Garden/GardenScene.swift            — Full layer restructure
Garden/GardenRenderer.swift         — AtmosphereState-based rendering
Garden/SeasonalLayer.swift          — Extended for new layer structure
Garden/Elements/GardenElement.swift — Protocol revised (see below)
Garden/Elements/Moss,Flower,Grass,Fog,Rain,Wind,Leaf — GrowthPhase support
```

#### GardenElement Protocol (revised)

```swift
// Current:
protocol GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode
}

// New:
protocol GardenElement {
    var elementType: ElementType { get }
    var preferredZone: PlacementZone { get }
    var estimatedNodes: Int { get }  // for budget tracking
    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode
}
```

Default implementations via protocol extension:
- `estimatedNodes` defaults to 3. `ElementSpec.estimatedNodes` is populated from each element's `estimatedNodes` property during manifest generation.
- `makeRandom(seed:)` and `nextFloat(random:min:max:)` remain unchanged
```

### Deleted

```
Garden/GardenGridLayout.swift       — Grid placement removed entirely
```

### New

```
Garden/AtmosphereEngine.swift       — Core analysis: entries → AtmosphereState
Garden/AtmosphereState.swift        — Value type holding all rendering parameters
Garden/MoodAtmosphere.swift         — Element pool definitions per mood
Garden/MoodPalette.swift            — Mood ratios → color direction (10-15%)
Garden/GrowthManager.swift          — Creation date → GrowthPhase
Garden/PlacementRule.swift          — Zone-based natural placement
Garden/BackgroundLayer.swift        — AI image layers + parallax + color blend
Garden/TransitionDirector.swift     — Fog-clearing transition choreography
Garden/Elements/ButterflyElement.swift
Garden/Elements/SunrayElement.swift
Garden/Elements/RainbowElement.swift
Garden/Elements/PuddleElement.swift
Garden/Elements/RippleElement.swift
Garden/Elements/VineElement.swift
Garden/Elements/MushroomElement.swift
```

### Resources

```
Resources/Backgrounds.xcassets
├── spring_sky, spring_hills, spring_ground  (@2x, @3x)
├── summer_sky, summer_hills, summer_ground  (@2x, @3x)
├── autumn_sky, autumn_hills, autumn_ground  (@2x, @3x)
└── winter_sky, winter_hills, winter_ground  (@2x, @3x)
```

---

## Testing

### Unit Tests (AtmosphereEngine — pure logic, no SpriteKit)

- **MoodPalette**: Verify brightness is equal across all mood ratios (Principle 1 enforcement). Verify influence ≤ 15%.
- **MoodAtmosphere**: Same seed → same elements (deterministic). Different seeds → different elements. Season bonus applied correctly. 2-4 elements per entry.
- **GrowthManager**: 0 days = seed, 1 = sprout, 2 = bloom, 3+ = mature.
- **PlacementRule**: Elements stay within zone bounds. Minimum distance respected. Same seed → same placement.
- **Node budget**: 30 full entries → estimated nodes ≤ 400.

### Visual Verification (Manual + Xcode Preview)

- Background display per season
- Color correction subtlety (barely noticeable shift)
- Transition timing measurement
- Growth phase visual differences
- Full 30-day render performance (Instruments: 60fps, node count)

### Integration Tests

- Mood record → AtmosphereEngine → GardenScene update flow
- SnapshotService compatibility with new layer structure (risk: 3-layer background with parallax offsets may render differently in offscreen capture — verify snapshot includes all layers correctly)
- Month transition with new rendering

---

## Known Risks

1. **SnapshotService**: The new multi-layer BackgroundLayer may behave differently during offscreen rendering. Verify early in implementation.
2. **Background asset quality**: AI-generated images may need multiple iterations to achieve consistent style. Placeholder gradients allow parallel development.
3. **Scope size**: This spec covers Engine + existing element migration + new elements + backgrounds + MoodSelector. Implementation plan should phase these into incremental milestones. Suggested priority order:
   1. AtmosphereEngine + AtmosphereState + existing element migration (core logic)
   2. BackgroundLayer + PlacementRule (visual foundation, placeholder gradients OK)
   3. New elements (ButterflyElement, SunrayElement, etc.)
   4. MoodSelector redesign + TransitionDirector
   5. Background AI images (replace placeholders)
