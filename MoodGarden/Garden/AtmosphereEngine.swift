import Foundation

enum AtmosphereEngine {
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
                mood: entry.mood, seed: entry.gardenSeed, season: season,
                previousMood: previousMood
            )

            // Apply consecutive density multiplier per spec:
            // 2 consecutive = 1.3x, 3+ consecutive = 1.6x
            let runLength = consecutiveRuns[entry.id] ?? 1
            let multiplier: Double = runLength >= 3 ? 1.6 : (runLength >= 2 ? 1.3 : 1.0)
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
        var runs: [UUID: Int] = [:]
        var currentRun = 1

        for index in 0..<sorted.count {
            if index > 0 {
                let prev = sorted[index - 1]
                let curr = sorted[index]
                let daysBetween =
                    Calendar.current.dateComponents(
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
            runs[sorted[index].id] = currentRun
        }

        return runs
    }
}
