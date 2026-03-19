import Testing

@testable import MoodGarden

struct MoodPaletteTests {
    @Test func emptyRatiosReturnZeroShift() {
        let result = MoodPalette.analyze(moodRatios: [:])
        #expect(result.hueShift == 0)
    }

    @Test func happyDominantProducesWarmShift() {
        let result = MoodPalette.analyze(moodRatios: [.happy: 1.0])
        #expect(result.hueShift > 0)  // positive = warm
    }

    @Test func sadDominantProducesCoolShift() {
        let result = MoodPalette.analyze(moodRatios: [.sad: 1.0])
        #expect(result.hueShift < 0)  // negative = cool
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
