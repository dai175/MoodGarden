# Mood Garden — MVP Specification v1.1

## Project overview

Mood Garden is an iOS app that transforms daily mood entries into a living garden landscape. Users tap once to record their mood, and the app renders it as a natural element (flowers, moss, rain, fog, wind). Over time, a monthly garden emerges.

This document defines the MVP scope. For the full concept and design philosophy, see `mood-garden-concept.md`.

## Tech stack

- **Platform:** iOS 26+, iPhone only
- **Language:** Swift 6.1+
- **UI framework:** SwiftUI (main UI, Liquid Glass compatible) + SpriteKit (garden rendering)
- **Data:** SwiftData (local-first, no server)
- **Architecture:** MVVM
- **Build SDK:** Xcode 26 / iOS 26 SDK
- **Package manager:** Swift Package Manager
- **Minimum deployment target:** iOS 26.0

## MVP scope

### In scope (v1.0)

1. Garden view (home screen)
2. Mood recording (7 moods, tap to select)
3. Garden element rendering (SpriteKit)
4. Monthly archive (browse past gardens)
5. Daily notification (local, configurable time)
6. Onboarding (minimal, 2–3 screens)
7. Settings (notification time, about)

### Out of scope (v2+)

- Garden resident (frog — a minimal, silent creature that lives in the garden; no name, no reactions, no gamification)
- Widgets (WidgetKit — small/medium view-only, large with inline recording)
- Additional garden themes (Japanese garden, Forest, Seaside, Desert)
- One-line memo per entry
- AI monthly insight report
- Apple Health integration (sleep + mood correlation)
- Music-influenced gardens (Apple Music / Spotify metadata → ambient layer shifts)
- Photo color absorption (extract color palette from photo → garden tint; photo not stored)
- iCloud sync
- Apple Watch app
- Localization (v1 is English only; Japanese planned for v2)
- Premium subscription / paywall (v1 is fully free)

For full v2+ design details, see Section 13 of `mood-garden-concept.md`.

---

## Data model

### MoodEntry

| Property | Type | Description |
|----------|------|-------------|
| id | UUID | Primary key |
| date | Date | Entry date (one per day, date-only granularity) |
| mood | MoodType | Enum: 7 mood types |
| gardenSeed | Int | Random seed for element variation |
| createdAt | Date | Timestamp of creation |

### MonthlyGarden

| Property | Type | Description |
|----------|------|-------------|
| id | UUID | Primary key |
| year | Int | Year (e.g. 2026) |
| month | Int | Month (1–12) |
| snapshotImage | Data? | Rendered garden image (PNG) for archive |
| completedAt | Date? | When the snapshot was taken |

### MoodType (enum)

```swift
enum MoodType: String, Codable, CaseIterable {
    case peaceful    // Moss, still water, soft light
    case happy       // Flowers, butterflies, warm breeze
    case energetic   // Tall grasses, bright sun, flowing stream
    case anxious     // Fog, tangled vines, low clouds
    case sad         // Gentle rain, puddles, gray sky
    case angry       // Strong wind, bent trees, rough waves
    case tired       // Fallen leaves, twilight, still air
}
```

---

## Screens

### 1. Garden view (home)

This is the main screen. The garden fills the entire display.

**Layout:**
- Full-screen SpriteKit scene as background
- Top: minimal status area (month name, small, semi-transparent)
- Bottom: mood selector (collapsed by default, expandable on tap)
- No navigation bar, no tab bar

**Behavior:**
- On launch, displays the current month's garden
- Garden shows all mood entries for the current month as accumulated elements
- If today has no entry, a subtle empty patch is visible in today's area
- If today has an entry, the mood selector is hidden
- Garden elements have slight ambient animation (swaying grass, drifting fog, rippling water)

**Mood selector:**
- A small floating button or indicator at the bottom
- Tap to expand into 7 mood icons in a horizontal row
- Each icon is minimal/abstract (line art style, not emoji)
- Tap a mood → element appears with a gentle "fog clearing" transition (0.8–1.2s)
- Selector collapses and fades after recording
- Only one entry per day; if already recorded, selector does not appear

### 2. Archive view

**Access:** Swipe up on garden view, or tap month name at top

**Layout:**
- Grid of monthly garden thumbnails (2 columns)
- Each thumbnail shows the rendered garden snapshot
- Month/year label below each thumbnail
- Current month appears at top with "In progress" label

**Behavior:**
- Tap a month to view full-screen garden (read-only, with ambient animation)
- Months with no entries show a dimmed empty garden placeholder

### 3. Onboarding

Shown only on first launch. 2–3 screens max.

- Screen 1: "Your garden grows with your emotions." (garden illustration)
- Screen 2: "Every mood is welcome here. There is no good or bad weather." (brief principle)
- Screen 3: "Record once a day. That's all." → Set notification time → Done

### 4. Settings

**Access:** Gear icon (top-right, semi-transparent) on garden view

**Options:**
- Notification time (time picker, default 21:00)
- Notification on/off toggle
- About (app version, focuswave link)
- Reset data (with confirmation)

---

## Garden rendering (SpriteKit)

### Scene structure

The garden is a single `SKScene` that represents one month.

**Coordinate system:**
- Scene size matches screen size
- Garden area divided into a grid (roughly 7 columns × 5 rows = 35 cells)
- Each day maps to a cell position (day 1 = top-left, day 31 = bottom-right, flowing left to right)
- Empty days (future or unrecorded) show bare ground

### Mood-to-element mapping

Each mood type generates a set of SpriteKit nodes. The `gardenSeed` on each MoodEntry provides deterministic randomization so the same entry always renders the same variation.

| MoodType | Primary elements | Color palette | Animation |
|----------|-----------------|---------------|-----------|
| peaceful | Moss patches, still water pool, soft glow | Greens, muted teal | Slow shimmer on water |
| happy | Small flowers, butterfly particle, warm light | Pinks, warm yellows | Gentle sway, butterfly drift |
| energetic | Tall grass blades, sun rays, stream | Bright greens, golden | Grass sway, water flow |
| anxious | Fog layer, tangled vine shapes, low cloud | Grays, muted purple | Fog drift, slow pulse |
| sad | Rain particles, puddle reflections, gray overlay | Cool blues, grays | Rain fall, ripple effect |
| angry | Wind streaks, bent tree shapes, wave patterns | Dark greens, charcoal | Strong sway, wind particles |
| tired | Fallen leaf particles, dim light, still scene | Browns, amber, dim | Slow leaf drift |

### Seasonal variation

Based on the current real-world month:

- **Spring (Mar–May):** Cherry blossom accents, brighter greens
- **Summer (Jun–Aug):** Dense foliage, warm lighting, firefly particles at night
- **Autumn (Sep–Nov):** Warm palette shift (amber, orange), falling leaf overlay
- **Winter (Dec–Feb):** Snow dusting on elements, cooler palette, bare branches

Season affects the ambient layer and color grading, not the core mood elements.

### Element variation

Each mood has 3–5 visual variants. The `gardenSeed` determines which variant is used. This ensures:
- Same mood on different days looks slightly different
- Same entry always renders identically (deterministic)
- "Nature never repeats itself" feeling

### Performance targets

- 60fps on iPhone 12 and later
- Scene should render within 200ms on cold start
- Keep total node count under 500 per scene
- Use texture atlases for common elements

---

## Notifications

- Local notifications only (no push server)
- Default time: 21:00
- Configurable in settings
- Notification text rotates through gentle questions:
  - "What's the weather in your garden today?"
  - "How does today feel?"
  - "Your garden is waiting quietly."
  - "One tap. That's all it takes."
- If user hasn't opened the app for 3+ days, reduce to every other day
- If 7+ days, reduce to twice a week
- Never increase frequency automatically

---

## Monthly snapshot

At the start of each new month (detected on app launch):
1. Check if previous month has any entries
2. If yes, render the previous month's garden scene offscreen
3. Capture as PNG image
4. Save to MonthlyGarden record
5. Display a brief, subtle toast: "Last month's garden has been saved."

---

## App lifecycle

### First launch
1. Show onboarding
2. Request notification permission
3. Set notification time
4. Show empty garden for current month

### Daily use
1. Open app → see current garden
2. If today unrecorded → mood selector available
3. Record mood → element appears → selector hides
4. User gazes at garden → closes app when ready

### Month transition
1. Open app in new month → snapshot previous month
2. Show fresh empty garden for new month
3. Previous month accessible in archive

---

## Design guidelines

### Color

- Background: deep dark green/black (`#0A1A12` to `#0D2818`)
- Text: soft white (`#E8E4DC`, opacity 0.8)
- Accent: focuswave teal (`#1D9E75`)
- UI elements: semi-transparent, never opaque
- No pure white, no pure black

### Typography

- System font (SF Pro) for UI text
- Lightweight/thin variants preferred
- Minimal text on screen at any time

### Interaction principles

- No haptic feedback on mood selection (keep it quiet)
- Transitions are slow and organic (0.8–1.5s)
- No bounce, no spring animations — use ease-in-out curves
- Never show loading spinners; if something loads, fade in when ready

### Sound

- No sound by default
- No background music
- Silence is intentional

### Liquid Glass (iOS 26)

- The garden view is full-screen SpriteKit — Liquid Glass does not apply here
- Settings and archive views use standard SwiftUI components and will inherit Liquid Glass styling automatically
- Let Liquid Glass translucency work in the user's favor: the garden colors should subtly bleed through system UI overlays (notifications, Control Center)
- Do not override or fight Liquid Glass on navigation bars or toolbars — embrace the translucency as it aligns with the app's minimal, quiet aesthetic
- Test that dark green/black garden backgrounds look good through Liquid Glass overlays

---

## File structure (suggested)

```
MoodGarden/
├── App/
│   ├── MoodGardenApp.swift
│   └── AppState.swift
├── Models/
│   ├── MoodEntry.swift
│   ├── MonthlyGarden.swift
│   └── MoodType.swift
├── Views/
│   ├── GardenView.swift          # Main screen (SwiftUI host)
│   ├── MoodSelectorView.swift    # Bottom mood picker
│   ├── ArchiveView.swift         # Monthly grid
│   ├── ArchiveDetailView.swift   # Full-screen past garden
│   ├── OnboardingView.swift      # First launch
│   └── SettingsView.swift
├── Garden/
│   ├── GardenScene.swift         # Main SKScene
│   ├── GardenRenderer.swift      # Maps MoodEntry[] → SKNodes
│   ├── Elements/
│   │   ├── MossElement.swift
│   │   ├── FlowerElement.swift
│   │   ├── RainElement.swift
│   │   ├── FogElement.swift
│   │   ├── WindElement.swift
│   │   ├── GrassElement.swift
│   │   └── LeafElement.swift
│   ├── SeasonalLayer.swift       # Season-based ambient effects
│   └── GardenSnapshotRenderer.swift  # Offscreen rendering for archive
├── Services/
│   ├── NotificationService.swift
│   └── SnapshotService.swift
├── Resources/
│   ├── Assets.xcassets
│   └── GardenTextures.atlas
└── Preview Content/
```

---

## Acceptance criteria

The MVP is complete when:

1. User can open the app and see an empty garden on first launch
2. User can tap a mood and see a garden element appear with gentle animation
3. Only one mood can be recorded per day
4. Garden accumulates elements over multiple days within a month
5. Same mood on different days produces visually distinct (but similar) elements
6. Garden has subtle ambient animation (swaying, drifting, rippling)
7. Garden visual changes with real-world season
8. Monthly archive shows grid of past gardens as thumbnails
9. Tapping a past month opens full-screen garden view
10. Previous month is automatically snapshotted when a new month begins
11. Daily notification fires at configured time with rotating message text
12. Notification frequency automatically decreases if user is inactive
13. Onboarding appears on first launch only
14. Settings allow notification time change and on/off toggle
15. App runs at 60fps on iPhone 12+
16. App works fully offline with no network dependency
17. Dark theme only (no light mode)
