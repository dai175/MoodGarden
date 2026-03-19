import CoreGraphics
import Foundation
import Testing

@testable import MoodGarden

struct PlacementRuleTests {
    private let sceneSize = CGSize(width: 400, height: 300)

    @Test func positionsAreWithinZoneBounds() {
        let specs = [
            ElementSpec(
                entryID: UUID(), elementType: .flower, seed: 1, phase: .bloom,
                zone: .hilltop, estimatedNodes: 3
            ),
            ElementSpec(
                entryID: UUID(), elementType: .raindrop, seed: 2, phase: .bloom,
                zone: .sky, estimatedNodes: 3
            ),
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
            ElementSpec(
                entryID: UUID(), elementType: .moss, seed: 42, phase: .bloom,
                zone: .waterside, estimatedNodes: 2
            )
        ]
        let a = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        let b = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        #expect(a == b)
    }

    @Test func minimumSpacingRespected() {
        let specs = (0..<8).map { i in
            ElementSpec(
                entryID: UUID(), elementType: .flower, seed: i, phase: .bloom,
                zone: .hilltop, estimatedNodes: 3
            )
        }
        let positions = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        let minDist: CGFloat = PlacementRule.minimumSpacing
        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let dx = positions[i].x - positions[j].x
                let dy = positions[i].y - positions[j].y
                let dist = sqrt(dx * dx + dy * dy)
                #expect(dist >= minDist * 0.8, "Elements \(i) and \(j) are too close: \(dist)")
            }
        }
    }
}
