import Foundation
import Testing

@testable import MoodGarden

struct AtmosphereEngineTests {
    private func makeEntry(mood: MoodType, daysAgo: Int = 0, seed: Int = 42) -> MoodEntry {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: fixedDate)!
        let entry = MoodEntry(mood: mood, date: date)
        entry.gardenSeed = seed
        return entry
    }

    private let fixedDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 19)
    )!

    @Test func emptyEntriesProduceEmptyState() {
        let state = AtmosphereEngine.analyze(entries: [], season: .spring, referenceDate: fixedDate)
        #expect(state == AtmosphereState.empty)
    }

    @Test func singleEntryProducesElements() {
        let entry = makeEntry(mood: .happy)
        let state = AtmosphereEngine.analyze(
            entries: [entry], season: .spring, referenceDate: fixedDate
        )
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
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .summer, referenceDate: fixedDate
        )
        #expect(state.moodRatios[.happy]! > 0.6)
        #expect(state.moodRatios[.sad]! > 0.3)
        #expect(state.dominantMood == .happy)
    }

    @Test func growthPhasesAreAssigned() {
        let entries = [
            makeEntry(mood: .happy, daysAgo: 5, seed: 1),
            makeEntry(mood: .peaceful, daysAgo: 0, seed: 2),
        ]
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        let phases = state.elementManifest.map(\.phase)
        #expect(phases.contains(.mature))  // 5 days ago
        #expect(phases.contains(.seed))  // today
    }

    @Test func nodeBudgetRespected() {
        // 30 entries — worst case scenario
        let entries = (0..<30).map { i in
            makeEntry(mood: MoodType.allCases[i % 7], daysAgo: i, seed: i)
        }
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .autumn, referenceDate: fixedDate
        )
        #expect(state.totalEstimatedNodes <= 400)
    }

    @Test func hueShiftIsWithinBounds() {
        let entries = [makeEntry(mood: .happy)]
        let state = AtmosphereEngine.analyze(
            entries: entries, season: .spring, referenceDate: fixedDate
        )
        #expect(abs(state.hueShift) <= 0.15)
    }

    @Test func consecutiveBonusIncreasesElements() {
        // 3 consecutive happy days -> 1.6x multiplier
        let consecutive = [
            makeEntry(mood: .happy, daysAgo: 2, seed: 10),
            makeEntry(mood: .happy, daysAgo: 1, seed: 11),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12),
        ]
        let stateConsec = AtmosphereEngine.analyze(
            entries: consecutive, season: .spring, referenceDate: fixedDate
        )

        // 3 non-consecutive happy days -> no multiplier
        let nonConsecutive = [
            makeEntry(mood: .happy, daysAgo: 6, seed: 10),
            makeEntry(mood: .happy, daysAgo: 3, seed: 11),
            makeEntry(mood: .happy, daysAgo: 0, seed: 12),
        ]
        let stateNonConsec = AtmosphereEngine.analyze(
            entries: nonConsecutive, season: .spring, referenceDate: fixedDate
        )

        #expect(stateConsec.elementManifest.count > stateNonConsec.elementManifest.count)
    }
}
