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
        let a = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42, season: .spring, previousMood: nil
        )
        let b = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42, season: .spring, previousMood: nil
        )
        #expect(a == b)
    }

    @Test func differentSeedProducesDifferentElements() {
        // With different seeds, elements or their order may differ
        var foundDifference = false
        for s in 0..<10 {
            let x = MoodAtmosphere.selectElements(
                mood: .happy, seed: s, season: .spring, previousMood: nil
            )
            let y = MoodAtmosphere.selectElements(
                mood: .happy, seed: s + 100, season: .spring, previousMood: nil
            )
            if x != y {
                foundDifference = true
                break
            }
        }
        #expect(foundDifference)
    }

    @Test func allMoodsProduceElements() {
        for mood in MoodType.allCases {
            let elements = MoodAtmosphere.selectElements(
                mood: mood, seed: 42, season: .spring, previousMood: nil
            )
            #expect(elements.count >= 2, "Mood \(mood) should produce at least 2 elements")
        }
    }

    @Test func elementsHavePreferredZones() {
        let elements = MoodAtmosphere.selectElements(
            mood: .sad, seed: 42, season: .spring, previousMood: nil
        )
        for element in elements {
            #expect(PlacementZone.allCases.contains(element.zone))
        }
    }

    @Test func seasonBonusAffectsSelection() {
        // Spring favors flower, butterfly, grass — run many seeds to detect statistical difference
        var springFlowerCount = 0
        var winterFlowerCount = 0
        for seed in 0..<50 {
            let spring = MoodAtmosphere.selectElements(
                mood: .happy, seed: seed, season: .spring, previousMood: nil
            )
            let winter = MoodAtmosphere.selectElements(
                mood: .happy, seed: seed, season: .winter, previousMood: nil
            )
            springFlowerCount += spring.filter { $0.elementType == .flower || $0.elementType == .butterfly }.count
            winterFlowerCount += winter.filter { $0.elementType == .flower || $0.elementType == .butterfly }.count
        }
        // Spring should produce at least as many flower/butterfly elements as winter
        #expect(springFlowerCount >= winterFlowerCount)
    }

    @Test func rainbowDetectionOnMoodTransition() {
        // sad → happy should sometimes produce rainbow
        var foundRainbow = false
        for seed in 0..<50 {
            let elements = MoodAtmosphere.selectElements(
                mood: .happy, seed: seed, season: .spring, previousMood: .sad
            )
            if elements.contains(where: { $0.elementType == .rainbow }) {
                foundRainbow = true
                break
            }
        }
        #expect(foundRainbow, "sad → happy transition should produce rainbow for some seeds")
    }

    @Test func deterministicWithSeasonAndPreviousMood() {
        let a = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42, season: .autumn, previousMood: .sad
        )
        let b = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42, season: .autumn, previousMood: .sad
        )
        #expect(a == b)
    }
}
