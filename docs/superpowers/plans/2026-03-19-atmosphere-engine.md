# Atmosphere Engine Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the garden from grid-based element placement to an atmosphere-driven living landscape where moods accumulate as weather in a cohesive scene.

**Architecture:** AtmosphereEngine (pure logic) analyzes MoodEntry[] and produces AtmosphereState — a value type describing what to render. GardenScene consumes AtmosphereState to render layered backgrounds, zone-based elements with growth phases, and seasonal effects. MoodSelectorView is redesigned for single-tap recording with fog-clearing transitions.

**Tech Stack:** Swift 6.1, SpriteKit (rendering), SwiftUI (UI), SwiftData (persistence), GameplayKit (deterministic random)

**Spec:** `docs/superpowers/specs/2026-03-19-atmosphere-engine-design.md`

---

## Chunk 1: Core Types and AtmosphereEngine

### Task 1: Core Type Definitions

**Files:**
- Create: `MoodGarden/Garden/GrowthPhase.swift`
- Create: `MoodGarden/Garden/PlacementZone.swift`
- Create: `MoodGarden/Garden/ElementType.swift`
- Create: `MoodGarden/Garden/ElementSpec.swift`
- Create: `MoodGarden/Garden/AtmosphereState.swift`
- Test: `MoodGardenTests/AtmosphereStateTests.swift`

These are the foundational value types used by all other components. No SpriteKit dependency.

- [x] **Step 1: Create GrowthPhase enum**

```swift
// MoodGarden/Garden/GrowthPhase.swift
import Foundation

enum GrowthPhase: Equatable, CaseIterable {
    case seed, sprout, bloom, mature

    var scale: CGFloat {
        switch self {
        case .seed: return 0.3
        case .sprout: return 0.6
        case .bloom: return 1.0
        case .mature: return 1.0
        }
    }

    var alpha: CGFloat {
        switch self {
        case .seed: return 0.4
        case .sprout: return 0.7
        case .bloom: return 1.0
        case .mature: return 0.9
        }
    }

    static func from(daysSinceCreation: Int) -> GrowthPhase {
        switch daysSinceCreation {
        case 0: return .seed
        case 1: return .sprout
        case 2: return .bloom
        default: return .mature
        }
    }
}
```

- [x] **Step 2: Create PlacementZone enum**

```swift
// MoodGarden/Garden/PlacementZone.swift
import CoreGraphics

enum PlacementZone: CaseIterable {
    case sky, hilltop, waterside, foreground, anywhere

    /// Zone bounds as ratios of sceneSize (origin at center).
    /// Preliminary — will be tuned when background images are finalized.
    var boundsRatio: CGRect {
        switch self {
        case .sky: return CGRect(x: -0.5, y: 0.15, width: 1.0, height: 0.35)
        case .hilltop: return CGRect(x: -0.5, y: -0.05, width: 0.5, height: 0.2)
        case .waterside: return CGRect(x: 0.0, y: -0.15, width: 0.5, height: 0.2)
        case .foreground: return CGRect(x: -0.5, y: -0.5, width: 1.0, height: 0.35)
        case .anywhere: return CGRect(x: -0.5, y: -0.5, width: 1.0, height: 1.0)
        }
    }

    func absoluteBounds(sceneSize: CGSize) -> CGRect {
        CGRect(
            x: boundsRatio.origin.x * sceneSize.width,
            y: boundsRatio.origin.y * sceneSize.height,
            width: boundsRatio.width * sceneSize.width,
            height: boundsRatio.height * sceneSize.height
        )
    }
}
```

- [x] **Step 3: Create ElementType enum**

```swift
// MoodGarden/Garden/ElementType.swift

enum ElementType: String, CaseIterable {
    // Ground elements
    case flower, moss, grass, vine, puddle, fallenLeaf, mushroom, pebble
    // Aerial elements
    case butterfly, raindrop, fog, wind, sunray, rainbow
    // Water elements
    case ripple, reflection
    // Ambient
    case warmLight, breeze, dimLight, shimmer

    var isGround: Bool {
        switch self {
        case .flower, .moss, .grass, .vine, .puddle, .fallenLeaf, .mushroom, .pebble:
            return true
        default:
            return false
        }
    }

    var isAerial: Bool {
        switch self {
        case .butterfly, .raindrop, .fog, .wind, .sunray, .rainbow:
            return true
        default:
            return false
        }
    }
}
```

- [x] **Step 4: Create ElementSpec struct**

```swift
// MoodGarden/Garden/ElementSpec.swift
import Foundation

struct ElementSpec: Equatable {
    let entryID: UUID
    let elementType: ElementType
    let seed: Int
    let phase: GrowthPhase
    let zone: PlacementZone
    let estimatedNodes: Int
}
```

- [x] **Step 5: Create AtmosphereState struct**

```swift
// MoodGarden/Garden/AtmosphereState.swift
import Foundation

struct AtmosphereState: Equatable {
    let moodRatios: [MoodType: Float]
    let dominantMood: MoodType?
    let hueShift: Float
    let elementManifest: [ElementSpec]

    var totalEstimatedNodes: Int {
        elementManifest.reduce(0) { $0 + $1.estimatedNodes }
    }

    static let empty = AtmosphereState(
        moodRatios: [:],
        dominantMood: nil,
        hueShift: 0,
        elementManifest: []
    )
}
```

- [x] **Step 6: Write tests for core types**

```swift
// MoodGardenTests/AtmosphereStateTests.swift
import Testing
@testable import MoodGarden

struct AtmosphereStateTests {
    @Test func growthPhaseFromDays() {
        #expect(GrowthPhase.from(daysSinceCreation: 0) == .seed)
        #expect(GrowthPhase.from(daysSinceCreation: 1) == .sprout)
        #expect(GrowthPhase.from(daysSinceCreation: 2) == .bloom)
        #expect(GrowthPhase.from(daysSinceCreation: 3) == .mature)
        #expect(GrowthPhase.from(daysSinceCreation: 30) == .mature)
    }

    @Test func growthPhaseScaleAndAlpha() {
        #expect(GrowthPhase.seed.scale == 0.3)
        #expect(GrowthPhase.bloom.scale == 1.0)
        #expect(GrowthPhase.seed.alpha == 0.4)
        #expect(GrowthPhase.bloom.alpha == 1.0)
    }

    @Test func placementZoneAbsoluteBounds() {
        let sceneSize = CGSize(width: 400, height: 300)
        let skyBounds = PlacementZone.sky.absoluteBounds(sceneSize: sceneSize)
        #expect(skyBounds.origin.x == -200)
        #expect(skyBounds.origin.y == 45) // 0.15 * 300
        #expect(skyBounds.width == 400)
        #expect(skyBounds.height == 105) // 0.35 * 300
    }

    @Test func atmosphereStateEmpty() {
        let state = AtmosphereState.empty
        #expect(state.moodRatios.isEmpty)
        #expect(state.dominantMood == nil)
        #expect(state.totalEstimatedNodes == 0)
    }

    @Test func atmosphereStateTotalNodes() {
        let specs = [
            ElementSpec(entryID: UUID(), elementType: .flower, seed: 1, phase: .bloom, zone: .hilltop, estimatedNodes: 3),
            ElementSpec(entryID: UUID(), elementType: .moss, seed: 2, phase: .mature, zone: .waterside, estimatedNodes: 2),
        ]
        let state = AtmosphereState(moodRatios: [.happy: 0.5, .peaceful: 0.5], dominantMood: .happy, hueShift: 0.1, elementManifest: specs)
        #expect(state.totalEstimatedNodes == 5)
    }
}
```

- [x] **Step 7: Build and run tests**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/AtmosphereStateTests`
Expected: All 5 tests PASS

- [x] **Step 8: Commit**

```bash
git add MoodGarden/Garden/GrowthPhase.swift MoodGarden/Garden/PlacementZone.swift \
  MoodGarden/Garden/ElementType.swift MoodGarden/Garden/ElementSpec.swift \
  MoodGarden/Garden/AtmosphereState.swift MoodGardenTests/AtmosphereStateTests.swift
git commit -m "feat(garden): add core types for atmosphere engine

GrowthPhase, PlacementZone, ElementType, ElementSpec, AtmosphereState"
```

---

### Task 2: GrowthManager

**Files:**
- Create: `MoodGarden/Garden/GrowthManager.swift`
- Test: `MoodGardenTests/GrowthManagerTests.swift`

Pure logic: computes GrowthPhase from entry creation date vs. current date.

- [x] **Step 1: Write failing tests**

```swift
// MoodGardenTests/GrowthManagerTests.swift
import Testing
@testable import MoodGarden

struct GrowthManagerTests {
    @Test func todayEntryIsSeed() {
        let today = Date()
        let phase = GrowthManager.phase(createdAt: today, referenceDate: today)
        #expect(phase == .seed)
    }

    @Test func yesterdayEntryIsSprout() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let phase = GrowthManager.phase(createdAt: yesterday, referenceDate: today)
        #expect(phase == .sprout)
    }

    @Test func twoDaysAgoIsBloom() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let phase = GrowthManager.phase(createdAt: twoDaysAgo, referenceDate: today)
        #expect(phase == .bloom)
    }

    @Test func threeDaysAgoIsMature() {
        let today = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let phase = GrowthManager.phase(createdAt: threeDaysAgo, referenceDate: today)
        #expect(phase == .mature)
    }

    @Test func thirtyDaysAgoIsMature() {
        let today = Date()
        let old = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let phase = GrowthManager.phase(createdAt: old, referenceDate: today)
        #expect(phase == .mature)
    }
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/GrowthManagerTests`
Expected: FAIL — `GrowthManager` not defined

- [x] **Step 3: Implement GrowthManager**

```swift
// MoodGarden/Garden/GrowthManager.swift
import Foundation

enum GrowthManager {
    static func phase(createdAt: Date, referenceDate: Date = Date()) -> GrowthPhase {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: createdAt), to: calendar.startOfDay(for: referenceDate)).day ?? 0
        return GrowthPhase.from(daysSinceCreation: max(0, days))
    }
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/GrowthManagerTests`
Expected: All 5 tests PASS

- [x] **Step 5: Commit**

```bash
git add MoodGarden/Garden/GrowthManager.swift MoodGardenTests/GrowthManagerTests.swift
git commit -m "feat(garden): add GrowthManager for element growth phases"
```

---

### Task 3: MoodPalette

**Files:**
- Create: `MoodGarden/Garden/MoodPalette.swift`
- Test: `MoodGardenTests/MoodPaletteTests.swift`

Pure logic: converts mood ratios into a hue shift direction. Critically, brightness is NEVER affected by mood ratios (Principle 1).

- [x] **Step 1: Write failing tests**

```swift
// MoodGardenTests/MoodPaletteTests.swift
import Testing
@testable import MoodGarden

struct MoodPaletteTests {
    @Test func emptyRatiosReturnZeroShift() {
        let result = MoodPalette.analyze(moodRatios: [:])
        #expect(result.hueShift == 0)
    }

    @Test func happyDominantProducesWarmShift() {
        let result = MoodPalette.analyze(moodRatios: [.happy: 1.0])
        #expect(result.hueShift > 0) // positive = warm
    }

    @Test func sadDominantProducesCoolShift() {
        let result = MoodPalette.analyze(moodRatios: [.sad: 1.0])
        #expect(result.hueShift < 0) // negative = cool
    }

    @Test func influenceIsCapped() {
        let result = MoodPalette.analyze(moodRatios: [.happy: 1.0])
        #expect(abs(result.hueShift) <= 0.15)
    }

    @Test func allMoodsProduceEqualBrightness() {
        // Principle 1: garden does not judge.
        // Every single mood at 100% should produce the same brightness.
        for mood in MoodType.allCases {
            let result = MoodPalette.analyze(moodRatios: [mood: 1.0])
            #expect(result.brightness == nil, "brightness must not be affected by mood ratios")
        }
    }

    @Test func mixedRatiosBlendShift() {
        let result = MoodPalette.analyze(moodRatios: [.happy: 0.5, .sad: 0.5])
        // Opposing shifts should partially cancel
        #expect(abs(result.hueShift) < 0.15)
    }
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/MoodPaletteTests`
Expected: FAIL

- [x] **Step 3: Implement MoodPalette**

```swift
// MoodGarden/Garden/MoodPalette.swift

enum MoodPalette {
    struct Result: Equatable {
        let hueShift: Float // -0.15 to 0.15. Positive = warm, negative = cool
        let brightness: Float? // Always nil — brightness is season-only, not mood-driven
    }

    /// Hue direction per mood. All are equally valid aesthetic directions.
    private static let hueDirections: [MoodType: Float] = [
        .peaceful: 0.02,    // slight warm green
        .happy: 0.12,       // warm gold
        .energetic: 0.08,   // bright green-gold
        .anxious: -0.05,    // slight cool purple
        .sad: -0.10,        // cool blue
        .angry: -0.03,      // deep green
        .tired: 0.04,       // amber
    ]

    static func analyze(moodRatios: [MoodType: Float]) -> Result {
        guard !moodRatios.isEmpty else {
            return Result(hueShift: 0, brightness: nil)
        }
        var shift: Float = 0
        for (mood, ratio) in moodRatios {
            shift += (hueDirections[mood] ?? 0) * ratio
        }
        let capped = max(-0.15, min(0.15, shift))
        return Result(hueShift: capped, brightness: nil)
    }
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/MoodPaletteTests`
Expected: All 6 tests PASS

- [x] **Step 5: Commit**

```bash
git add MoodGarden/Garden/MoodPalette.swift MoodGardenTests/MoodPaletteTests.swift
git commit -m "feat(garden): add MoodPalette for non-judgmental color direction"
```

---

### Task 4: MoodAtmosphere (Element Pool)

**Files:**
- Create: `MoodGarden/Garden/MoodAtmosphere.swift`
- Test: `MoodGardenTests/MoodAtmosphereTests.swift`

Selects 2-4 elements from each mood's pool based on seed, season, and context.

- [x] **Step 1: Write failing tests**

```swift
// MoodGardenTests/MoodAtmosphereTests.swift
import Testing
@testable import MoodGarden

struct MoodAtmosphereTests {
    @Test func selectsBaseElements() {
        let elements = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42, season: .spring, previousMood: nil
        )
        #expect(elements.count >= 2)
        #expect(elements.count <= 4)
    }

    @Test func deterministicWithSameSeed() {
        let a = MoodAtmosphere.selectElements(mood: .happy, seed: 42, season: .spring, previousMood: nil)
        let b = MoodAtmosphere.selectElements(mood: .happy, seed: 42, season: .spring, previousMood: nil)
        #expect(a == b)
    }

    @Test func differentSeedProducesDifferentElements() {
        let a = MoodAtmosphere.selectElements(mood: .happy, seed: 42, season: .spring, previousMood: nil)
        let b = MoodAtmosphere.selectElements(mood: .happy, seed: 999, season: .spring, previousMood: nil)
        // At minimum the combination should differ sometimes
        // With different seeds, elements or their order may differ
        // We test this probabilistically — at least one difference in 10 tries
        var foundDifference = false
        for s in 0..<10 {
            let x = MoodAtmosphere.selectElements(mood: .happy, seed: s, season: .spring, previousMood: nil)
            let y = MoodAtmosphere.selectElements(mood: .happy, seed: s + 100, season: .spring, previousMood: nil)
            if x != y { foundDifference = true; break }
        }
        #expect(foundDifference)
    }

    @Test func allMoodsProduceElements() {
        for mood in MoodType.allCases {
            let elements = MoodAtmosphere.selectElements(
                mood: mood, seed: 42, season: .summer, previousMood: nil
            )
            #expect(elements.count >= 2, "Mood \(mood) should produce at least 2 elements")
        }
    }

    @Test func elementsHavePreferredZones() {
        let elements = MoodAtmosphere.selectElements(
            mood: .sad, seed: 42, season: .autumn, previousMood: nil
        )
        for element in elements {
            // Every element must have a valid zone
            #expect(PlacementZone.allCases.contains(element.zone))
        }
    }
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/MoodAtmosphereTests`
Expected: FAIL

- [x] **Step 3: Implement MoodAtmosphere**

```swift
// MoodGarden/Garden/MoodAtmosphere.swift
import GameplayKit

enum MoodAtmosphere {
    struct SelectedElement: Equatable {
        let elementType: ElementType
        let zone: PlacementZone
        let estimatedNodes: Int
    }

    private struct PoolEntry {
        let elementType: ElementType
        let zone: PlacementZone
        let estimatedNodes: Int
    }

    private static let pools: [MoodType: (base: [PoolEntry], supplementary: [PoolEntry])] = [
        .peaceful: (
            base: [
                PoolEntry(elementType: .moss, zone: .waterside, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
                PoolEntry(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
                PoolEntry(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .happy: (
            base: [
                PoolEntry(elementType: .flower, zone: .hilltop, estimatedNodes: 3),
                PoolEntry(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                PoolEntry(elementType: .butterfly, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .breeze, zone: .sky, estimatedNodes: 1),
                PoolEntry(elementType: .shimmer, zone: .anywhere, estimatedNodes: 1),
            ]
        ),
        .energetic: (
            base: [
                PoolEntry(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .sunray, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .wind, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .flower, zone: .foreground, estimatedNodes: 3),
            ]
        ),
        .anxious: (
            base: [
                PoolEntry(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                PoolEntry(elementType: .vine, zone: .foreground, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
                PoolEntry(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                PoolEntry(elementType: .fog, zone: .sky, estimatedNodes: 2),
            ]
        ),
        .sad: (
            base: [
                PoolEntry(elementType: .raindrop, zone: .sky, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .puddle, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                PoolEntry(elementType: .dimLight, zone: .sky, estimatedNodes: 1),
            ]
        ),
        .angry: (
            base: [
                PoolEntry(elementType: .wind, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
            ],
            supplementary: [
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
                PoolEntry(elementType: .fog, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .wind, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .tired: (
            base: [
                PoolEntry(elementType: .fallenLeaf, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                PoolEntry(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                PoolEntry(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
            ]
        ),
    ]

    static func selectElements(
        mood: MoodType,
        seed: Int,
        season: Season,
        previousMood: MoodType?
    ) -> [SelectedElement] {
        guard let pool = pools[mood] else { return [] }
        let random = GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))

        var selected: [SelectedElement] = []

        // Select 1-2 base elements
        let baseCount = pool.base.count == 1 ? 1 : (1 + random.nextInt(upperBound: 2)).clamped(to: 1...pool.base.count)
        let shuffledBase = pool.base.shuffled(using: random)
        for i in 0..<baseCount {
            let entry = shuffledBase[i]
            selected.append(SelectedElement(
                elementType: entry.elementType, zone: entry.zone, estimatedNodes: entry.estimatedNodes
            ))
        }

        // Select 0-2 supplementary elements (50% chance each)
        let shuffledSupp = pool.supplementary.shuffled(using: random)
        var suppCount = 0
        for entry in shuffledSupp where suppCount < 2 {
            if random.nextUniform() > 0.5 {
                selected.append(SelectedElement(
                    elementType: entry.elementType, zone: entry.zone, estimatedNodes: entry.estimatedNodes
                ))
                suppCount += 1
            }
        }

        // Ensure minimum of 2 elements
        if selected.count < 2, let fallback = pool.supplementary.first {
            selected.append(SelectedElement(
                elementType: fallback.elementType, zone: fallback.zone, estimatedNodes: fallback.estimatedNodes
            ))
        }

        return selected
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/MoodAtmosphereTests`
Expected: All 5 tests PASS

- [x] **Step 5: Commit**

```bash
git add MoodGarden/Garden/MoodAtmosphere.swift MoodGardenTests/MoodAtmosphereTests.swift
git commit -m "feat(garden): add MoodAtmosphere element pool with deterministic selection"
```

---

### Task 5: PlacementRule

**Files:**
- Create: `MoodGarden/Garden/PlacementRule.swift`
- Test: `MoodGardenTests/PlacementRuleTests.swift`

Converts ElementSpecs into scene positions using zone-based placement with minimum spacing.

- [x] **Step 1: Write failing tests**

```swift
// MoodGardenTests/PlacementRuleTests.swift
import Testing
@testable import MoodGarden

struct PlacementRuleTests {
    private let sceneSize = CGSize(width: 400, height: 300)

    @Test func positionsAreWithinZoneBounds() {
        let specs = [
            ElementSpec(entryID: UUID(), elementType: .flower, seed: 1, phase: .bloom, zone: .hilltop, estimatedNodes: 3),
            ElementSpec(entryID: UUID(), elementType: .raindrop, seed: 2, phase: .bloom, zone: .sky, estimatedNodes: 3),
        ]
        let positions = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        #expect(positions.count == 2)

        let hilltopBounds = PlacementZone.hilltop.absoluteBounds(sceneSize: sceneSize)
        #expect(hilltopBounds.contains(positions[0]))

        let skyBounds = PlacementZone.sky.absoluteBounds(sceneSize: sceneSize)
        #expect(skyBounds.contains(positions[1]))
    }

    @Test func deterministicPositions() {
        let specs = [
            ElementSpec(entryID: UUID(), elementType: .moss, seed: 42, phase: .bloom, zone: .waterside, estimatedNodes: 2),
        ]
        let a = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        let b = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        #expect(a == b)
    }

    @Test func minimumSpacingRespected() {
        // Place many elements in the same zone
        let specs = (0..<8).map { i in
            ElementSpec(entryID: UUID(), elementType: .flower, seed: i, phase: .bloom, zone: .hilltop, estimatedNodes: 3)
        }
        let positions = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        let minDist: CGFloat = PlacementRule.minimumSpacing
        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let dx = positions[i].x - positions[j].x
                let dy = positions[i].y - positions[j].y
                let dist = sqrt(dx * dx + dy * dy)
                // Allow some tolerance since placement may fallback if zone is full
                #expect(dist >= minDist * 0.8, "Elements \(i) and \(j) are too close: \(dist)")
            }
        }
    }
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/PlacementRuleTests`
Expected: FAIL

- [x] **Step 3: Implement PlacementRule**

```swift
// MoodGarden/Garden/PlacementRule.swift
import CoreGraphics
import GameplayKit

enum PlacementRule {
    static let minimumSpacing: CGFloat = 20

    static func computePositions(for specs: [ElementSpec], sceneSize: CGSize) -> [CGPoint] {
        var positions: [CGPoint] = []

        for spec in specs {
            let random = GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(spec.seed)))
            let bounds = spec.zone.absoluteBounds(sceneSize: sceneSize)
            var placed = false

            // Try up to 20 times to find a non-overlapping position
            for _ in 0..<20 {
                let x = bounds.origin.x + CGFloat(random.nextUniform()) * bounds.width
                let y = bounds.origin.y + CGFloat(random.nextUniform()) * bounds.height
                let candidate = CGPoint(x: x, y: y)

                let tooClose = positions.contains { existing in
                    let dx = existing.x - candidate.x
                    let dy = existing.y - candidate.y
                    return sqrt(dx * dx + dy * dy) < minimumSpacing
                }

                if !tooClose {
                    positions.append(candidate)
                    placed = true
                    break
                }
            }

            // Fallback: place anyway if zone is crowded
            if !placed {
                let x = bounds.origin.x + CGFloat(random.nextUniform()) * bounds.width
                let y = bounds.origin.y + CGFloat(random.nextUniform()) * bounds.height
                positions.append(CGPoint(x: x, y: y))
            }
        }

        return positions
    }
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/PlacementRuleTests`
Expected: All 3 tests PASS

- [x] **Step 5: Commit**

```bash
git add MoodGarden/Garden/PlacementRule.swift MoodGardenTests/PlacementRuleTests.swift
git commit -m "feat(garden): add PlacementRule for zone-based element positioning"
```

---

### Task 6: AtmosphereEngine

**Files:**
- Create: `MoodGarden/Garden/AtmosphereEngine.swift`
- Test: `MoodGardenTests/AtmosphereEngineTests.swift`

The central orchestrator: takes MoodEntry array + Season → produces AtmosphereState.

- [x] **Step 1: Write failing tests**

```swift
// MoodGardenTests/AtmosphereEngineTests.swift
import Foundation
import SwiftData
import Testing
@testable import MoodGarden

struct AtmosphereEngineTests {
    private func makeEntry(mood: MoodType, daysAgo: Int = 0, seed: Int = 42) -> MoodEntry {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let entry = MoodEntry(mood: mood, date: date)
        // Override the random seed for deterministic tests
        entry.gardenSeed = seed
        return entry
    }

    private let fixedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 19))!

    @Test func emptyEntriesProduceEmptyState() {
        let state = AtmosphereEngine.analyze(entries: [], season: .spring, referenceDate: fixedDate)
        #expect(state == AtmosphereState.empty)
    }

    @Test func singleEntryProducesElements() {
        let entry = makeEntry(mood: .happy)
        let state = AtmosphereEngine.analyze(entries: [entry], season: .spring, referenceDate: fixedDate)
        #expect(!state.elementManifest.isEmpty)
        #expect(state.moodRatios[.happy] == 1.0)
        #expect(state.dominantMood == .happy)
    }

    @Test func mixedEntriesProduceCorrectRatios() {
        let entries = [
            makeEntry(mood: .happy, daysAgo: 2, seed: 1),
            makeEntry(mood: .happy, daysAgo: 1, seed: 2),
            makeEntry(mood: .sad, daysAgo: 0, seed: 3),
        ]
        let state = AtmosphereEngine.analyze(entries: entries, season: .summer, referenceDate: fixedDate)
        #expect(state.moodRatios[.happy]! > 0.6)
        #expect(state.moodRatios[.sad]! > 0.3)
        #expect(state.dominantMood == .happy)
    }

    @Test func growthPhasesAreAssigned() {
        let entries = [
            makeEntry(mood: .happy, daysAgo: 5, seed: 1),
            makeEntry(mood: .peaceful, daysAgo: 0, seed: 2),
        ]
        let state = AtmosphereEngine.analyze(entries: entries, season: .spring, referenceDate: fixedDate)
        let phases = state.elementManifest.map(\.phase)
        #expect(phases.contains(.mature)) // 5 days ago
        #expect(phases.contains(.seed))   // today
    }

    @Test func nodeBudgetRespected() {
        // 30 entries — worst case scenario
        let entries = (0..<30).map { i in
            makeEntry(mood: MoodType.allCases[i % 7], daysAgo: i, seed: i)
        }
        let state = AtmosphereEngine.analyze(entries: entries, season: .autumn, referenceDate: fixedDate)
        #expect(state.totalEstimatedNodes <= 400)
    }

    @Test func hueShiftIsWithinBounds() {
        let entries = [makeEntry(mood: .happy)]
        let state = AtmosphereEngine.analyze(entries: entries, season: .spring, referenceDate: fixedDate)
        #expect(abs(state.hueShift) <= 0.15)
    }

    @Test func consecutiveBonusIncreasesElements() {
        // 3 consecutive happy days → 1.6× multiplier
        let consecutive = [
            makeEntry(mood: .happy, daysAgo: 2, seed: 10),
            makeEntry(mood: .happy, daysAgo: 1, seed: 11),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12),
        ]
        let stateConsec = AtmosphereEngine.analyze(entries: consecutive, season: .spring, referenceDate: fixedDate)

        // 3 non-consecutive happy days → no multiplier
        let nonConsecutive = [
            makeEntry(mood: .happy, daysAgo: 6, seed: 10),
            makeEntry(mood: .happy, daysAgo: 3, seed: 11),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12),
        ]
        let stateNonConsec = AtmosphereEngine.analyze(entries: nonConsecutive, season: .spring, referenceDate: fixedDate)

        #expect(stateConsec.elementManifest.count > stateNonConsec.elementManifest.count)
    }
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/AtmosphereEngineTests`
Expected: FAIL

- [x] **Step 3: Implement AtmosphereEngine**

```swift
// MoodGarden/Garden/AtmosphereEngine.swift
import Foundation

enum AtmosphereEngine {
    static func analyze(entries: [MoodEntry], season: Season, referenceDate: Date = Date()) -> AtmosphereState {
        guard !entries.isEmpty else { return .empty }

        let sorted = entries.sorted { $0.date < $1.date }

        // 1. Compute mood ratios
        var moodCounts: [MoodType: Int] = [:]
        for entry in sorted {
            moodCounts[entry.mood, default: 0] += 1
        }
        let total = Float(entries.count)
        let moodRatios = moodCounts.mapValues { Float($0) / total }
        let dominantMood = moodRatios.max(by: { $0.value < $1.value })?.key

        // 2. Compute hue shift via MoodPalette
        let palette = MoodPalette.analyze(moodRatios: moodRatios)

        // 3. Compute consecutive bonuses
        let consecutiveRuns = computeConsecutiveRuns(sorted)

        // 4. Generate element manifest
        var manifest: [ElementSpec] = []
        var budgetRemaining = 400

        for (index, entry) in sorted.enumerated() {
            let phase = GrowthManager.phase(createdAt: entry.createdAt, referenceDate: referenceDate)
            let previousMood = index > 0 ? sorted[index - 1].mood : nil
            let elements = MoodAtmosphere.selectElements(
                mood: entry.mood, seed: entry.gardenSeed, season: season, previousMood: previousMood
            )

            // Apply consecutive density multiplier per spec:
            // 2 consecutive = 1.3×, 3+ consecutive = 1.6×
            let runLength = consecutiveRuns[entry.id] ?? 1
            let multiplier: Double = runLength >= 3 ? 1.6 : (runLength >= 2 ? 1.3 : 1.0)
            let targetCount = Int(ceil(Double(elements.count) * multiplier))

            var entrySpecs: [ElementSpec] = []
            // Add base elements
            for (i, element) in elements.enumerated() {
                if budgetRemaining < element.estimatedNodes { break }
                entrySpecs.append(ElementSpec(
                    entryID: entry.id,
                    elementType: element.elementType,
                    seed: entry.gardenSeed &+ i,
                    phase: phase,
                    zone: element.zone,
                    estimatedNodes: element.estimatedNodes
                ))
                budgetRemaining -= element.estimatedNodes
            }

            // Add bonus elements from pool to reach targetCount
            var bonusIndex = 0
            while entrySpecs.count < targetCount, bonusIndex < elements.count {
                let bonus = elements[bonusIndex % elements.count]
                if budgetRemaining < bonus.estimatedNodes { break }
                entrySpecs.append(ElementSpec(
                    entryID: entry.id,
                    elementType: bonus.elementType,
                    seed: entry.gardenSeed &+ elements.count &+ bonusIndex,
                    phase: phase,
                    zone: bonus.zone,
                    estimatedNodes: bonus.estimatedNodes
                ))
                budgetRemaining -= bonus.estimatedNodes
                bonusIndex += 1
            }

            manifest.append(contentsOf: entrySpecs)
        }

        return AtmosphereState(
            moodRatios: moodRatios,
            dominantMood: dominantMood,
            hueShift: palette.hueShift,
            elementManifest: manifest
        )
    }

    /// Returns [entryID: consecutive run length] for same-mood streaks
    private static func computeConsecutiveRuns(_ sorted: [MoodEntry]) -> [UUID: Int] {
        var runs: [UUID: Int] = [:]
        var currentRun = 1

        for i in 0..<sorted.count {
            if i > 0 {
                let prev = sorted[i - 1]
                let curr = sorted[i]
                let daysBetween = Calendar.current.dateComponents(
                    [.day],
                    from: Calendar.current.startOfDay(for: prev.date),
                    to: Calendar.current.startOfDay(for: curr.date)
                ).day ?? 0

                if curr.mood == prev.mood && daysBetween == 1 {
                    currentRun += 1
                } else {
                    currentRun = 1
                }
            }
            runs[sorted[i].id] = currentRun
        }

        return runs
    }
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests/AtmosphereEngineTests`
Expected: All 7 tests PASS

- [x] **Step 5: Commit**

```bash
git add MoodGarden/Garden/AtmosphereEngine.swift MoodGardenTests/AtmosphereEngineTests.swift
git commit -m "feat(garden): add AtmosphereEngine orchestrating mood analysis pipeline"
```

---

## Chunk 2: Visual Foundation (BackgroundLayer + GardenElement Migration)

### Task 7: Revise GardenElement Protocol

**Files:**
- Modify: `MoodGarden/Garden/Elements/GardenElement.swift`
- Modify: `MoodGarden/Garden/Elements/MossElement.swift` (and all 6 other elements)
- Test: Build verification

Update the protocol to accept GrowthPhase and sceneSize. Migrate all 7 existing elements.

- [x] **Step 1: Update GardenElement protocol**

Replace contents of `MoodGarden/Garden/Elements/GardenElement.swift`:

```swift
import GameplayKit
import SpriteKit

protocol GardenElement {
    var elementType: ElementType { get }
    var preferredZone: PlacementZone { get }
    var estimatedNodes: Int { get }
    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode
}

extension GardenElement {
    var estimatedNodes: Int { 3 }

    func makeRandom(seed: Int) -> GKMersenneTwisterRandomSource {
        GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))
    }

    func nextFloat(_ random: GKMersenneTwisterRandomSource, min: Float, max: Float) -> CGFloat {
        CGFloat(random.nextUniform() * (max - min) + min)
    }

    /// Applies growth phase scale and alpha to a node.
    func applyGrowthPhase(_ phase: GrowthPhase, to node: SKNode) {
        node.setScale(phase.scale)
        node.alpha = phase.alpha
    }

    /// Returns an animation speed multiplier based on growth phase.
    /// .seed = no animation, .sprout = slow, .bloom = full, .mature = minimal
    func animationSpeed(for phase: GrowthPhase) -> CGFloat {
        switch phase {
        case .seed: return 0
        case .sprout: return 0.5
        case .bloom: return 1.0
        case .mature: return 0.3
        }
    }
}
```

- [x] **Step 2: Migrate MossElement**

Update `MoodGarden/Garden/Elements/MossElement.swift` — change method signature and add growth phase support. The core drawing logic stays the same, but uses `sceneSize` instead of `cellSize` and applies phase-based scaling.

```swift
import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    let elementType = ElementType.moss
    let preferredZone = PlacementZone.waterside

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        // Use sceneSize to derive a cell-like area for element sizing
        let refSize = CGSize(width: sceneSize.width / 8, height: sceneSize.height / 6)
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for patchIndex in 0..<patchCount {
            let width = nextFloat(random, min: 0.3, max: 0.6) * refSize.width
            let height = nextFloat(random, min: 0.2, max: 0.4) * refSize.height
            let ellipse = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            ellipse.fillColor = MoodType.peaceful.uiColor
            ellipse.strokeColor = .clear
            ellipse.alpha = nextFloat(random, min: 0.5, max: 0.8)

            ellipse.position = CGPoint(
                x: nextFloat(random, min: -0.25, max: 0.25) * refSize.width,
                y: nextFloat(random, min: -0.25, max: 0.25) * refSize.height
            )

            let speed = animationSpeed(for: phase)
            if speed > 0 {
                let pulseDuration = nextFloat(random, min: 1.2, max: 1.5) / speed
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: ellipse.alpha * 0.7, duration: pulseDuration),
                    SKAction.fadeAlpha(to: ellipse.alpha, duration: pulseDuration),
                ])
                let phaseDelay = SKAction.wait(forDuration: Double(patchIndex) * 0.4)
                ellipse.run(.sequence([phaseDelay, .repeatForever(pulse)]))

                let scaleUp = SKAction.scale(to: 1.03, duration: nextFloat(random, min: 0.8, max: 1.2) / speed)
                let scaleDown = SKAction.scale(to: 0.97, duration: nextFloat(random, min: 0.8, max: 1.2) / speed)
                scaleUp.timingMode = .easeInEaseOut
                scaleDown.timingMode = .easeInEaseOut
                ellipse.run(.repeatForever(.sequence([scaleUp, scaleDown])))
            }

            container.addChild(ellipse)
        }

        applyGrowthPhase(phase, to: container)
        return container
    }
}
```

- [x] **Step 3: Migrate remaining 6 elements**

Apply the same pattern to each: change `createNode(seed:cellSize:)` → `createNode(seed:phase:sceneSize:)`, derive `refSize` from `sceneSize`, add `elementType`, `preferredZone`, apply `applyGrowthPhase` and `animationSpeed`. Core drawing logic stays the same.

Files to modify:
- `FlowerElement.swift` — elementType: .flower, zone: .hilltop
- `GrassElement.swift` — elementType: .grass, zone: .hilltop
- `FogElement.swift` — elementType: .fog, zone: .anywhere
- `RainElement.swift` — elementType: .raindrop, zone: .sky
- `WindElement.swift` — elementType: .wind, zone: .sky
- `LeafElement.swift` — elementType: .fallenLeaf, zone: .foreground

- [x] **Step 4: Update GardenRenderer to use new protocol**

Modify `MoodGarden/Garden/GardenRenderer.swift` to accept `ElementSpec` and `AtmosphereState`:

```swift
import SpriteKit

struct GardenRenderer {
    private static let elementMap: [ElementType: any GardenElement] = [
        .moss: MossElement(),
        .flower: FlowerElement(),
        .grass: GrassElement(),
        .fog: FogElement(),
        .raindrop: RainElement(),
        .wind: WindElement(),
        .fallenLeaf: LeafElement(),
    ]

    func createNode(for spec: ElementSpec, sceneSize: CGSize) -> SKNode {
        guard let element = Self.elementMap[spec.elementType] else {
            // Unimplemented element types render as empty nodes for now
            return SKNode()
        }
        let node = element.createNode(seed: spec.seed, phase: spec.phase, sceneSize: sceneSize)
        node.name = "element_\(spec.entryID.uuidString.prefix(8))_\(spec.elementType.rawValue)"
        return node
    }

    func createNodes(
        for specs: [ElementSpec],
        positions: [CGPoint],
        sceneSize: CGSize
    ) -> [(node: SKNode, position: CGPoint)] {
        zip(specs, positions).map { spec, position in
            let node = createNode(for: spec, sceneSize: sceneSize)
            return (node: node, position: position)
        }
    }
}
```

- [x] **Step 5: Build to verify compilation**

Run: `xcodebuild build -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: BUILD SUCCEEDED (existing tests may not run yet due to GardenScene changes pending)

- [x] **Step 6: Commit**

```bash
git add MoodGarden/Garden/Elements/ MoodGarden/Garden/GardenRenderer.swift
git commit -m "refactor(garden): migrate elements to new protocol with GrowthPhase support"
```

---

### Task 8: BackgroundLayer with Placeholder Gradients

**Files:**
- Create: `MoodGarden/Garden/BackgroundLayer.swift`

Creates the 3-layer background system. Uses gradient placeholders until AI images are ready.

- [x] **Step 1: Implement BackgroundLayer**

```swift
// MoodGarden/Garden/BackgroundLayer.swift
import SpriteKit
import UIKit

final class BackgroundLayer: SKNode {
    private let skySprite = SKSpriteNode()
    private let hillsSprite = SKSpriteNode()
    private let groundSprite = SKSpriteNode()

    override init() {
        super.init()
        skySprite.zPosition = 0
        hillsSprite.zPosition = 1
        groundSprite.zPosition = 2
        addChild(skySprite)
        addChild(hillsSprite)
        addChild(groundSprite)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(season: Season, sceneSize: CGSize) {
        let textures = Self.textures(for: season, sceneSize: sceneSize)
        skySprite.texture = textures.sky
        skySprite.size = sceneSize
        hillsSprite.texture = textures.hills
        hillsSprite.size = sceneSize
        groundSprite.texture = textures.ground
        groundSprite.size = sceneSize

        startParallax()
    }

    func applyHueShift(_ hueShift: Float) {
        // colorBlendFactor applies a tint over the sprite.
        // Positive hueShift → warm tint, negative → cool tint.
        let color: UIColor
        if hueShift >= 0 {
            color = UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1)
        } else {
            color = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1)
        }
        let factor = CGFloat(abs(hueShift)) // already capped at 0.15
        for sprite in [skySprite, hillsSprite, groundSprite] {
            sprite.color = color
            sprite.colorBlendFactor = factor
        }
    }

    // MARK: - Parallax

    private func startParallax() {
        skySprite.removeAllActions()
        hillsSprite.removeAllActions()

        let skyDrift = SKAction.sequence([
            SKAction.moveBy(x: 2, y: 0, duration: 4),
            SKAction.moveBy(x: -2, y: 0, duration: 4),
        ])
        skyDrift.timingMode = .easeInEaseOut
        skySprite.run(.repeatForever(skyDrift))

        let hillsDrift = SKAction.sequence([
            SKAction.moveBy(x: 4, y: 0, duration: 5),
            SKAction.moveBy(x: -4, y: 0, duration: 5),
        ])
        hillsDrift.timingMode = .easeInEaseOut
        hillsSprite.run(.repeatForever(hillsDrift))
        // groundSprite is static for stability
    }

    // MARK: - Placeholder textures (gradient-based, replaced later with AI images)

    private static func textures(
        for season: Season,
        sceneSize: CGSize
    ) -> (sky: SKTexture, hills: SKTexture, ground: SKTexture) {
        let colors = seasonColors(season)
        return (
            sky: gradientTexture(size: sceneSize, topColor: colors.skyTop, bottomColor: colors.skyBottom),
            hills: gradientTexture(size: sceneSize, topColor: colors.hillsTop, bottomColor: colors.hillsBottom),
            ground: gradientTexture(size: sceneSize, topColor: colors.groundTop, bottomColor: colors.groundBottom)
        )
    }

    private static func seasonColors(_ season: Season) -> (
        skyTop: UIColor, skyBottom: UIColor,
        hillsTop: UIColor, hillsBottom: UIColor,
        groundTop: UIColor, groundBottom: UIColor
    ) {
        switch season {
        case .spring:
            return (
                skyTop: UIColor(red: 0.08, green: 0.15, blue: 0.10, alpha: 1),
                skyBottom: UIColor(red: 0.06, green: 0.12, blue: 0.08, alpha: 1),
                hillsTop: UIColor(red: 0.05, green: 0.18, blue: 0.10, alpha: 1),
                hillsBottom: UIColor(red: 0.04, green: 0.14, blue: 0.08, alpha: 1),
                groundTop: UIColor(red: 0.04, green: 0.12, blue: 0.07, alpha: 1),
                groundBottom: UIColor(red: 0.039, green: 0.102, blue: 0.071, alpha: 1)
            )
        case .summer:
            return (
                skyTop: UIColor(red: 0.06, green: 0.14, blue: 0.08, alpha: 1),
                skyBottom: UIColor(red: 0.05, green: 0.12, blue: 0.07, alpha: 1),
                hillsTop: UIColor(red: 0.04, green: 0.16, blue: 0.08, alpha: 1),
                hillsBottom: UIColor(red: 0.04, green: 0.13, blue: 0.07, alpha: 1),
                groundTop: UIColor(red: 0.04, green: 0.11, blue: 0.06, alpha: 1),
                groundBottom: UIColor(red: 0.039, green: 0.102, blue: 0.071, alpha: 1)
            )
        case .autumn:
            return (
                skyTop: UIColor(red: 0.10, green: 0.12, blue: 0.08, alpha: 1),
                skyBottom: UIColor(red: 0.08, green: 0.10, blue: 0.06, alpha: 1),
                hillsTop: UIColor(red: 0.10, green: 0.10, blue: 0.06, alpha: 1),
                hillsBottom: UIColor(red: 0.08, green: 0.09, blue: 0.05, alpha: 1),
                groundTop: UIColor(red: 0.07, green: 0.08, blue: 0.05, alpha: 1),
                groundBottom: UIColor(red: 0.039, green: 0.102, blue: 0.071, alpha: 1)
            )
        case .winter:
            return (
                skyTop: UIColor(red: 0.06, green: 0.10, blue: 0.14, alpha: 1),
                skyBottom: UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1),
                hillsTop: UIColor(red: 0.05, green: 0.09, blue: 0.12, alpha: 1),
                hillsBottom: UIColor(red: 0.04, green: 0.08, blue: 0.10, alpha: 1),
                groundTop: UIColor(red: 0.04, green: 0.07, blue: 0.09, alpha: 1),
                groundBottom: UIColor(red: 0.039, green: 0.102, blue: 0.071, alpha: 1)
            )
        }
    }

    private static func gradientTexture(size: CGSize, topColor: UIColor, bottomColor: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = [topColor.cgColor, bottomColor.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }
}
```

- [x] **Step 2: Build to verify**

Run: `xcodebuild build -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: BUILD SUCCEEDED

- [x] **Step 3: Commit**

```bash
git add MoodGarden/Garden/BackgroundLayer.swift
git commit -m "feat(garden): add BackgroundLayer with placeholder gradient textures"
```

---

### Task 9: Rebuild GardenScene with New Layer Structure

**Files:**
- Modify: `MoodGarden/Garden/GardenScene.swift`
- Delete: `MoodGarden/Garden/GardenGridLayout.swift`
- Delete: `MoodGarden/Garden/GardenElementData.swift`

This is the core integration: rewire GardenScene to use AtmosphereState, BackgroundLayer, and zone-based rendering.

- [x] **Step 1: Rewrite GardenScene**

Replace contents of `MoodGarden/Garden/GardenScene.swift`:

```swift
import SpriteKit
import UIKit

final class GardenScene: SKScene {
    private let renderer = GardenRenderer()
    private let backgroundLayer = BackgroundLayer()
    private let groundElementsLayer = SKNode()
    private let aerialElementsLayer = SKNode()
    private let seasonalLayer = SeasonalLayer()
    private let atmosphereOverlay = SKShapeNode()

    private var currentState: AtmosphereState = .empty
    private var currentSeason: Season = .spring

    override init() {
        super.init(size: CGSize(width: 350, height: 250))
        commonInit()
    }

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = DesignConstants.Colors.backgroundPrimaryUIColor
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        backgroundLayer.zPosition = 0
        addChild(backgroundLayer)

        groundElementsLayer.zPosition = 10
        addChild(groundElementsLayer)

        aerialElementsLayer.zPosition = 20
        addChild(aerialElementsLayer)

        seasonalLayer.zPosition = 30
        addChild(seasonalLayer)

        atmosphereOverlay.zPosition = 40
        atmosphereOverlay.strokeColor = .clear
        addChild(atmosphereOverlay)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isPaused = false
        view.isPaused = false
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        backgroundLayer.configure(season: currentSeason, sceneSize: size)
        seasonalLayer.configure(season: currentSeason, sceneSize: size)
        rebuildElements()
        updateAtmosphereOverlay()
    }

    func configureSeason(month: Int) {
        currentSeason = Season.from(month: month)
        guard size.width > 0, size.height > 0 else { return }
        backgroundLayer.configure(season: currentSeason, sceneSize: size)
        seasonalLayer.configure(season: currentSeason, sceneSize: size)
    }

    func configure(with state: AtmosphereState) {
        guard state != currentState else { return }
        currentState = state
        backgroundLayer.applyHueShift(state.hueShift)
        rebuildElements()
        updateAtmosphereOverlay()
    }

    func addElements(from newSpecs: [ElementSpec], animated: Bool) {
        guard size.width > 0, size.height > 0 else { return }
        let positions = PlacementRule.computePositions(for: newSpecs, sceneSize: size)
        let nodes = renderer.createNodes(for: newSpecs, positions: positions, sceneSize: size)

        for (node, position) in nodes {
            let targetLayer = newSpecs.first(where: {
                node.name?.contains($0.elementType.rawValue) ?? false
            })?.elementType.isGround == true ? groundElementsLayer : aerialElementsLayer

            node.position = position

            if animated {
                node.alpha = 0
                node.setScale(0.1)
                targetLayer.addChild(node)
                let fadeIn = SKAction.fadeAlpha(to: node.alpha > 0 ? node.alpha : 1.0, duration: 1.0)
                let scaleUp = SKAction.scale(to: 1.0, duration: 1.0)
                fadeIn.timingMode = .easeOut
                scaleUp.timingMode = .easeOut
                node.run(.group([fadeIn, scaleUp]))
            } else {
                targetLayer.addChild(node)
            }
        }
    }

    private func rebuildElements() {
        groundElementsLayer.removeAllChildren()
        aerialElementsLayer.removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }

        let specs = currentState.elementManifest
        let positions = PlacementRule.computePositions(for: specs, sceneSize: size)
        let nodes = renderer.createNodes(for: specs, positions: positions, sceneSize: size)

        for (index, (node, position)) in nodes.enumerated() {
            node.position = position
            let spec = specs[index]
            if spec.elementType.isGround {
                groundElementsLayer.addChild(node)
            } else {
                aerialElementsLayer.addChild(node)
            }
        }
    }

    private func updateAtmosphereOverlay() {
        atmosphereOverlay.removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }
        let rect = CGRect(
            x: -size.width / 2, y: -size.height / 2,
            width: size.width, height: size.height
        )
        atmosphereOverlay.path = CGPath(rect: rect, transform: nil)
        atmosphereOverlay.fillColor = currentSeason.tintColor
        atmosphereOverlay.alpha = 0.5
    }
}
```

- [x] **Step 2: Update GardenView to use AtmosphereEngine**

Modify `MoodGarden/Views/GardenView.swift` — replace the `makeElementData` / grid-based flow with AtmosphereEngine:

```swift
// Key changes in GardenView.swift:
// 1. Remove makeElementData() helper
// 2. Replace updateScene() to use AtmosphereEngine
// 3. Replace onChange to use addElements for animated new entry

private func updateScene() {
    let month = Calendar.current.component(.month, from: Date())
    let season = Season.from(month: month)
    gardenScene.configureSeason(month: month)
    let state = AtmosphereEngine.analyze(entries: viewModel.currentMonthEntries, season: season)
    gardenScene.configure(with: state)
}
```

The `onChange` handler for new entries should compute the new entry's specs via AtmosphereEngine and call `gardenScene.addElements(from:animated:)` for the incremental addition.

- [x] **Step 3: Update GardenViewModel if needed**

`GardenViewModel` likely needs no changes at this stage — it still provides `currentMonthEntries: [MoodEntry]`. The transformation to `AtmosphereState` happens in `GardenView`.

- [x] **Step 4: Update ArchiveDetailView**

Modify `MoodGarden/Views/ArchiveDetailView.swift` — replace `GardenElementData` usage with `AtmosphereEngine`:

```swift
.onAppear {
    let season = Season.from(month: month)
    let state = AtmosphereEngine.analyze(entries: entries, season: season)
    detailScene.configureSeason(month: month)
    detailScene.configure(with: state)
}
```

- [x] **Step 5: Delete GardenGridLayout.swift and GardenElementData.swift**

Now that all consumers have been updated, remove the old grid-based files:

```bash
rm MoodGarden/Garden/GardenGridLayout.swift
rm MoodGarden/Garden/GardenElementData.swift
```

- [x] **Step 6: Fix any remaining compilation errors**

Search for any remaining references to `GardenElementData`, `GardenGridLayout`, or the old `createNode(for:cellSize:)` signature and update them. Also remove the existing fog transition code from the old `addEntry(_:animated:)` method — fog transitions are now handled by `TransitionDirector` (Task 12).

- [x] **Step 7: Build and run existing tests**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests`
Expected: All tests PASS (including new AtmosphereEngine tests and legacy tests)

- [x] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(garden): rebuild GardenScene with atmosphere-driven layer structure

Replace grid-based layout with zone-based placement.
Delete GardenGridLayout and GardenElementData.
Integrate AtmosphereEngine into GardenView and ArchiveDetailView."
```

---

## Chunk 3: New Elements

### Task 10: Implement New Element Types

**Files:**
- Create: `MoodGarden/Garden/Elements/ButterflyElement.swift`
- Create: `MoodGarden/Garden/Elements/SunrayElement.swift`
- Create: `MoodGarden/Garden/Elements/RainbowElement.swift`
- Create: `MoodGarden/Garden/Elements/PuddleElement.swift`
- Create: `MoodGarden/Garden/Elements/RippleElement.swift`
- Create: `MoodGarden/Garden/Elements/VineElement.swift`
- Create: `MoodGarden/Garden/Elements/MushroomElement.swift`
- Modify: `MoodGarden/Garden/GardenRenderer.swift` (register new elements)

Each new element follows the same `GardenElement` protocol pattern as the existing 7 elements. They use `SKShapeNode` procedural drawing with `GrowthPhase` support.

- [ ] **Step 1: Implement all 7 new elements**

Each element should:
- Conform to `GardenElement` protocol
- Set `elementType` and `preferredZone`
- Use `makeRandom(seed:)` for deterministic randomization
- Apply `applyGrowthPhase(phase, to:)` at the end
- Use `animationSpeed(for: phase)` to scale animation timing

Element sketches (implement with SKShapeNode procedural drawing):

| Element | Visual | Nodes | Animation |
|---------|--------|-------|-----------|
| ButterflyElement | 2 wing ellipses + body line | 3 | Wing flap (scale y), drift path |
| SunrayElement | 2-3 thin rectangles radiating | 2-3 | Alpha pulse, slow rotation |
| RainbowElement | Arc of colored thin lines | 3-5 | Slow fade in/out |
| PuddleElement | Flat ellipse with slight shimmer | 1-2 | Alpha ripple |
| RippleElement | Concentric circles expanding | 2-3 | Scale + fade repeating cycle |
| VineElement | Curved path with small leaf nodes | 2-3 | Gentle sway rotation |
| MushroomElement | Ellipse cap + rectangle stem | 2 | Subtle scale pulse |

- [ ] **Step 2: Register new elements in GardenRenderer**

Add to `GardenRenderer.elementMap`:

```swift
private static let elementMap: [ElementType: any GardenElement] = [
    // Existing
    .moss: MossElement(),
    .flower: FlowerElement(),
    .grass: GrassElement(),
    .fog: FogElement(),
    .raindrop: RainElement(),
    .wind: WindElement(),
    .fallenLeaf: LeafElement(),
    // New
    .butterfly: ButterflyElement(),
    .sunray: SunrayElement(),
    .rainbow: RainbowElement(),
    .puddle: PuddleElement(),
    .ripple: RippleElement(),
    .vine: VineElement(),
    .mushroom: MushroomElement(),
]
```

Note: ElementTypes that don't have a dedicated class yet (warmLight, breeze, dimLight, shimmer, pebble, reflection) will render as empty nodes. These can be implemented later as polish items.

- [ ] **Step 3: Build and verify**

Run: `xcodebuild build -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Run all tests**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add MoodGarden/Garden/Elements/ MoodGarden/Garden/GardenRenderer.swift
git commit -m "feat(garden): add 7 new element types for enriched mood expression"
```

---

## Chunk 4: MoodSelector Redesign + Transition

### Task 11: MoodSelector Arc Layout and Single-Tap

**Files:**
- Modify: `MoodGarden/Views/MoodSelectorView.swift`
- Modify: `MoodGarden/App/AppState.swift` (add totalRecordCount)

- [ ] **Step 1: Add totalRecordCount to AppState**

Add to `MoodGarden/App/AppState.swift` following the existing `@AppStorage` pattern:

```swift
// In Keys enum:
static let totalRecordCount = "totalRecordCount"

// Property:
@ObservationIgnored
@AppStorage(Keys.totalRecordCount) private var _totalRecordCount: Int = 0

var totalRecordCount: Int {
    get {
        access(keyPath: \.totalRecordCount)
        return _totalRecordCount
    }
    set {
        withMutation(keyPath: \.totalRecordCount) {
            _totalRecordCount = newValue
        }
    }
}
```

- [ ] **Step 2: Redesign MoodSelectorView**

Rewrite `MoodGarden/Views/MoodSelectorView.swift` with:
- Arc layout for mood icons
- Single tap to confirm
- 3-second undo window (once only per day)
- No labels, no haptic feedback
- easeInEaseOut animations only

The view should:
1. Show a small glowing dot when collapsed (not recorded today)
2. Expand into arc on tap
3. Single tap selects mood → triggers recording + transition
4. Show "undo" text for 3 seconds, then fade
5. If undo is used, selector reappears but next recording has no undo

Undo tracking: Use a `@State private var undoUsedThisSession = false` flag. Once undo is used, the flag is set to true and no further undo is offered for the remainder of the session. This is session-scoped (not persisted), matching the spec's "once only" intent — if the user re-opens the app, they get a fresh undo opportunity for a new recording.

- [ ] **Step 3: Increment totalRecordCount on recording**

In `MoodSelectorView`'s selectMood handler, increment `appState.totalRecordCount`.

- [ ] **Step 4: Build and verify**

Run: `xcodebuild build -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add MoodGarden/Views/MoodSelectorView.swift MoodGarden/App/AppState.swift
git commit -m "feat(views): redesign MoodSelector with arc layout and single-tap confirm"
```

---

### Task 12: TransitionDirector (Fog-Clearing Effect)

**Files:**
- Create: `MoodGarden/Garden/TransitionDirector.swift`
- Modify: `MoodGarden/Garden/GardenScene.swift` (integrate transition)

- [ ] **Step 1: Implement TransitionDirector**

```swift
// MoodGarden/Garden/TransitionDirector.swift
import SpriteKit
import UIKit

final class TransitionDirector {
    /// Computes transition duration based on cumulative record count.
    static func duration(totalRecords: Int) -> TimeInterval {
        switch totalRecords {
        case 0...10: return 2.0
        case 11...30: return 1.7
        default: return 1.5
        }
    }

    /// Runs the fog-clearing transition on the scene.
    /// Phase 1: Stillness (0.3s) — existing animations slow
    /// Phase 2: Fog rises (variable) — mood-tinted fog
    /// Phase 3: Fog clears (variable) — new elements revealed
    static func runTransition(
        on scene: SKScene,
        mood: MoodType,
        totalRecords: Int,
        completion: @escaping () -> Void
    ) {
        let total = duration(totalRecords: totalRecords)
        let phase1 = 0.3
        let remaining = total - phase1
        let phase2 = remaining * 0.4
        let phase3 = remaining * 0.6

        // Phase 1: Stillness — slow existing animations
        scene.speed = 0.3

        let fogRect = CGRect(
            x: -scene.size.width / 2, y: -scene.size.height / 2,
            width: scene.size.width, height: scene.size.height
        )
        let fogOverlay = SKShapeNode(rect: fogRect)
        fogOverlay.name = "fogTransition"
        fogOverlay.fillColor = mood.uiColor.withAlphaComponent(0.15)
        fogOverlay.strokeColor = .clear
        fogOverlay.alpha = 0
        fogOverlay.zPosition = 100
        scene.addChild(fogOverlay)

        let phase1Action = SKAction.wait(forDuration: phase1)

        // Phase 2: Fog rises
        let fogIn = SKAction.fadeAlpha(to: 0.6, duration: phase2)
        fogIn.timingMode = .easeInEaseOut

        // Phase 3: Fog clears
        let restoreSpeed = SKAction.run { scene.speed = 1.0 }
        let fogOut = SKAction.fadeOut(withDuration: phase3)
        fogOut.timingMode = .easeInEaseOut
        let cleanup = SKAction.run {
            fogOverlay.removeFromParent()
            completion()
        }

        fogOverlay.run(.sequence([
            phase1Action,
            fogIn,
            restoreSpeed,
            fogOut,
            cleanup,
        ]))
    }
}
```

- [ ] **Step 2: Integrate into GardenScene**

Add a convenience method to GardenScene:

```swift
func performTransition(mood: MoodType, totalRecords: Int, newSpecs: [ElementSpec]) {
    TransitionDirector.runTransition(on: self, mood: mood, totalRecords: totalRecords) { [weak self] in
        self?.addElements(from: newSpecs, animated: true)
    }
}
```

- [ ] **Step 3: Wire transition into GardenView**

Update the `onChange` handler in GardenView to call `performTransition` when a new entry is recorded, passing `appState.totalRecordCount`.

- [ ] **Step 4: Build and verify**

Run: `xcodebuild build -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Run all tests**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests`
Expected: All tests PASS

- [ ] **Step 6: Commit**

```bash
git add MoodGarden/Garden/TransitionDirector.swift MoodGarden/Garden/GardenScene.swift \
  MoodGarden/Views/GardenView.swift
git commit -m "feat(garden): add TransitionDirector with adaptive fog-clearing effect"
```

---

## Chunk 5: Integration and Cleanup

### Task 13: SnapshotService Compatibility

**Files:**
- Modify: `MoodGarden/Services/SnapshotService.swift` (if needed)
- Test: Manual verification

- [ ] **Step 1: Verify SnapshotService works with new scene**

Read `SnapshotService.swift` and verify it creates a GardenScene, configures it, and renders to image. The new GardenScene now accepts `AtmosphereState` instead of `[GardenElementData]`, so the service needs to call `AtmosphereEngine.analyze()` before configuring.

- [ ] **Step 2: Update SnapshotService if needed**

The snapshot rendering flow should be:
```swift
let state = AtmosphereEngine.analyze(entries: entries, season: season)
scene.configureSeason(month: month)
scene.configure(with: state)
// render to image
```

- [ ] **Step 3: Build and run all tests**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MoodGardenTests`
Expected: All tests PASS

- [ ] **Step 4: Commit**

```bash
git add MoodGarden/Services/SnapshotService.swift
git commit -m "fix(services): update SnapshotService for atmosphere-driven scene"
```

---

### Task 14: Clean Up and Final Verification

**Files:**
- Remove any unused imports, dead code referencing old grid system
- Verify all files compile cleanly

- [ ] **Step 1: Search for dead references**

Search the codebase for any remaining references to:
- `GardenGridLayout`
- `GardenElementData`
- `cellSize` in element contexts
- Old `createNode(seed:cellSize:)` signature

- [ ] **Step 2: Fix any remaining issues**

- [ ] **Step 3: Run full test suite**

Run: `xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: All tests PASS, BUILD SUCCEEDED

- [ ] **Step 4: Run linter**

Run: `make lint`
Expected: No errors

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chore(garden): clean up dead references from grid-based system"
```

---

## Summary

| Chunk | Tasks | What it delivers |
|-------|-------|-----------------|
| 1: Core Types + Engine | Tasks 1-6 | AtmosphereEngine pipeline (pure logic, fully tested) |
| 2: Visual Foundation | Tasks 7-9 | New GardenScene with backgrounds, migrated elements |
| 3: New Elements | Task 10 | 7 new element types for enriched mood expression |
| 4: MoodSelector + Transition | Tasks 11-12 | Redesigned recording flow with fog-clearing |
| 5: Integration | Tasks 13-14 | SnapshotService compatibility, cleanup |

Each chunk produces a compilable, testable milestone. Background AI images are not included in this plan — they are produced separately and dropped into `Resources/Backgrounds.xcassets` to replace the gradient placeholders.
