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

    @Test func mixedRatiosBlendShift() {
        let result = MoodPalette.analyze(moodRatios: [.happy: 0.5, .sad: 0.5])
        // Opposing shifts should partially cancel
        #expect(abs(result.hueShift) < 0.15)
    }
}
