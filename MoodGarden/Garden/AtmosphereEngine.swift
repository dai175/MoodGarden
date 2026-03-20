import Foundation

enum AtmosphereEngine {
    /// Maximum total estimated nodes across all elements in a single garden render.
    /// Balances visual richness with SpriteKit frame-rate on older devices.
    private static let nodeBudget = 400
    /// Consecutive same-mood entries >= this threshold receive the larger density bonus (1.6×).
    private static let longRunThreshold = 3
    /// Consecutive same-mood entries >= this threshold receive a moderate density bonus (1.3×).
    private static let shortRunThreshold = 2
    private static let longRunMultiplier = 1.6
    private static let shortRunMultiplier = 1.3

    static func analyze(
        entries: [MoodEntry], season: Season, referenceDate: Date = Date()
    ) -> AtmosphereState {
        guard !entries.isEmpty else { return .empty }

        let sorted = entries.sorted { $0.date < $1.date }

        // 1. Compute mood ratios
        var moodCounts: [MoodType: Int] = [:]
        for entry in sorted {
            moodCounts[entry.mood, default: 0] += 1
        }
        let total = Float(entries.count)
        let moodRatios = moodCounts.mapValues { Float($0) / total }
        let dominantMood =
            moodRatios
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .max(by: { $0.value < $1.value })?.key

        // 2. Compute hue shift via MoodPalette
        let palette = MoodPalette.analyze(moodRatios: moodRatios)

        // 3. Compute consecutive bonuses
        let consecutiveRuns = computeConsecutiveRuns(sorted)

        // 4. Generate element manifest
        var manifest: [ElementSpec] = []
        var budgetRemaining = nodeBudget
        let referenceStartOfDay = Calendar.current.startOfDay(for: referenceDate)

        for entry in sorted {
            let phase = GrowthManager.phase(
                createdAt: entry.createdAt, referenceStartOfDay: referenceStartOfDay
            )
            let elements = MoodAtmosphere.selectElements(
                mood: entry.mood, seed: entry.gardenSeed
            )

            // Apply consecutive density multiplier per spec:
            // 2 consecutive = 1.3x, 3+ consecutive = 1.6x
            let runLength = consecutiveRuns[entry.id] ?? 1
            let multiplier: Double =
                runLength >= longRunThreshold
                ? longRunMultiplier : (runLength >= shortRunThreshold ? shortRunMultiplier : 1.0)
            let targetCount = Int(ceil(Double(elements.count) * multiplier))

            var entrySpecs: [ElementSpec] = []
            // Add base elements
            for (elemIndex, element) in elements.enumerated() {
                if budgetRemaining < element.estimatedNodes { break }
                entrySpecs.append(
                    ElementSpec(
                        entryID: entry.id,
                        elementType: element.elementType,
                        seed: entry.gardenSeed &+ elemIndex,
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
                entrySpecs.append(
                    ElementSpec(
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
        guard !sorted.isEmpty else { return [:] }

        let calendar = Calendar.current
        // Pre-compute startOfDay for each entry to avoid redundant Calendar calls
        let startOfDays = sorted.map { calendar.startOfDay(for: $0.date) }

        var runs: [UUID: Int] = [:]
        var currentRun = 1

        for index in 0..<sorted.count {
            if index > 0 {
                let daysBetween =
                    calendar.dateComponents(
                        [.day],
                        from: startOfDays[index - 1],
                        to: startOfDays[index]
                    ).day ?? 0

                if sorted[index].mood == sorted[index - 1].mood && daysBetween == 1 {
                    currentRun += 1
                } else {
                    currentRun = 1
                }
            }
            runs[sorted[index].id] = currentRun
        }

        return runs
    }
}
