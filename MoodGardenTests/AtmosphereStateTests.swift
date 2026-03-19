import CoreGraphics
import Foundation
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
        #expect(skyBounds.origin.y == 45)  // 0.15 * 300
        #expect(skyBounds.width == 400)
        #expect(skyBounds.height == 105)  // 0.35 * 300
    }

    @Test func atmosphereStateEmpty() {
        let state = AtmosphereState.empty
        #expect(state.moodRatios.isEmpty)
        #expect(state.dominantMood == nil)
        #expect(state.totalEstimatedNodes == 0)
    }

    @Test func atmosphereStateTotalNodes() {
        let specs = [
            ElementSpec(
                entryID: UUID(), elementType: .flower, seed: 1, phase: .bloom,
                zone: .hilltop, estimatedNodes: 3
            ),
            ElementSpec(
                entryID: UUID(), elementType: .moss, seed: 2, phase: .mature,
                zone: .waterside, estimatedNodes: 2
            ),
        ]
        let state = AtmosphereState(
            moodRatios: [.happy: 0.5, .peaceful: 0.5], dominantMood: .happy,
            hueShift: 0.1, elementManifest: specs
        )
        #expect(state.totalEstimatedNodes == 5)
    }
}
