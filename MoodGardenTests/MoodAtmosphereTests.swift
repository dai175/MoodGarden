import Testing

@testable import MoodGarden

struct MoodAtmosphereTests {
    @Test func selectsBaseElements() {
        let elements = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42
        )
        #expect(elements.count >= 2)
        #expect(elements.count <= 4)
    }

    @Test func deterministicWithSameSeed() {
        let a = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42
        )
        let b = MoodAtmosphere.selectElements(
            mood: .happy, seed: 42
        )
        #expect(a == b)
    }

    @Test func differentSeedProducesDifferentElements() {
        // With different seeds, elements or their order may differ
        var foundDifference = false
        for s in 0..<10 {
            let x = MoodAtmosphere.selectElements(
                mood: .happy, seed: s
            )
            let y = MoodAtmosphere.selectElements(
                mood: .happy, seed: s + 100
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
                mood: mood, seed: 42
            )
            #expect(elements.count >= 2, "Mood \(mood) should produce at least 2 elements")
        }
    }

    @Test func elementsHavePreferredZones() {
        let elements = MoodAtmosphere.selectElements(
            mood: .sad, seed: 42
        )
        for element in elements {
            #expect(PlacementZone.allCases.contains(element.zone))
        }
    }
}
