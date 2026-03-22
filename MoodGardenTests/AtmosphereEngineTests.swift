import Foundation
import SwiftData
import Testing

@testable import MoodGarden

@MainActor
struct AtmosphereEngineTests {
    private let fixedDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 19)
    )!

    private func makeEntry(
        mood: MoodType, daysAgo: Int = 0, seed: Int = 42, in context: ModelContext
    ) -> MoodEntry {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: fixedDate)!
        let entry = MoodEntry(mood: mood, date: date)
        entry.gardenSeed = seed
        context.insert(entry)
        return entry
    }

    @Test func emptyEntriesProduceEmptyState() {
        let state = AtmosphereEngine.analyze(entries: [], season: .spring, referenceDate: fixedDate)
        #expect(state == AtmosphereState.empty)
    }

    @Test func singleEntryProducesElements() throws {
        let container = try TestHelpers.makeModelContainer()
        let entry = makeEntry(mood: .happy, in: container.mainContext)
        let state = AtmosphereEngine.analyze(
            entries: [entry], season: .spring, referenceDate: fixedDate
        )
        #expect(!state.elementManifest.isEmpty)
        #expect(state.moodRatios[.happy] == 1.0)
        #expect(state.dominantMood == .happy)
    }

    @Test func mixedEntriesProduceCorrectRatios() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let entries = [
            makeEntry(mood: .happy, daysAgo: 2, seed: 1, in: context),
            makeEntry(mood: .happy, daysAgo: 1, seed: 2, in: context),
            makeEntry(mood: .sad, daysAgo: 0, seed: 3, in: context),
        ]
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        #expect(state.moodRatios[.happy]! > 0.6)
        #expect(state.moodRatios[.sad]! > 0.3)
        #expect(state.dominantMood == .happy)
    }

    @Test func growthPhasesAreAssigned() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let entries = [
            makeEntry(mood: .happy, daysAgo: 5, seed: 1, in: context),
            makeEntry(mood: .peaceful, daysAgo: 0, seed: 2, in: context),
        ]
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        let phases = state.elementManifest.map(\.phase)
        #expect(phases.contains(.mature))  // 5 days ago
        #expect(phases.contains(.seed))  // today
    }

    @Test func nodeBudgetRespected() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        // 30 entries — worst case scenario
        let entries = (0..<30).map { i in
            makeEntry(mood: MoodType.allCases[i % 7], daysAgo: i, seed: i, in: context)
        }
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        #expect(state.totalEstimatedNodes <= 400)
    }

    @Test func hueShiftIsWithinBounds() throws {
        let container = try TestHelpers.makeModelContainer()
        let entries = [makeEntry(mood: .happy, in: container.mainContext)]
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        #expect(abs(state.hueShift) <= 0.15)
    }

    @Test func consecutiveBonusIncreasesElements() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        // 3 consecutive happy days -> 1.6x multiplier
        let consecutive = [
            makeEntry(mood: .happy, daysAgo: 2, seed: 10, in: context),
            makeEntry(mood: .happy, daysAgo: 1, seed: 11, in: context),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12, in: context),
        ]
        let stateConsec = AtmosphereEngine.analyze(
            entries: consecutive, season: .spring, referenceDate: fixedDate
        )

        // 3 non-consecutive happy days -> no multiplier
        let nonConsecutive = [
            makeEntry(mood: .happy, daysAgo: 6, seed: 10, in: context),
            makeEntry(mood: .happy, daysAgo: 3, seed: 11, in: context),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12, in: context),
        ]
        let stateNonConsec = AtmosphereEngine.analyze(
            entries: nonConsecutive, season: .spring, referenceDate: fixedDate
        )

        #expect(stateConsec.elementManifest.count > stateNonConsec.elementManifest.count)
    }

    @Test func seasonAffectsElementSelection() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        // Mix happy + energetic moods to maximize spring-favored elements (flower, butterfly, grass)
        // Energetic has grass as base (spring-favored), happy has flower as base
        let moods: [MoodType] = [.happy, .energetic]
        let entries = (0..<30).map { i in
            makeEntry(mood: moods[i % 2], daysAgo: i, seed: i * 7 + 3, in: context)
        }
        let springState = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        let winterState = AtmosphereEngine.analyze(
            entries: entries, season: .winter, referenceDate: fixedDate
        )
        // Spring bonus favors flower/butterfly/grass in supplementary selection
        let springFavored: Set<ElementType> = [.flower, .butterfly, .grass]
        let springCount = springState.elementManifest.filter { springFavored.contains($0.elementType) }.count
        let winterCount = winterState.elementManifest.filter { springFavored.contains($0.elementType) }.count
        #expect(springCount > winterCount, "Spring should produce more spring-favored elements than winter")
    }
}
