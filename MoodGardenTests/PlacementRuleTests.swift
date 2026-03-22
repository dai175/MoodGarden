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

    @Test func positionsRespectZoneBoundsStrictly() {
        let zones: [PlacementZone] = [.hilltop, .waterside, .sky]
        let specs = zones.enumerated().map { index, zone in
            ElementSpec(
                entryID: UUID(), elementType: .flower, seed: index * 7,
                phase: .bloom, zone: zone, estimatedNodes: 2
            )
        }
        let positions = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        #expect(positions.count == specs.count)

        for (index, zone) in zones.enumerated() {
            let bounds = zone.absoluteBounds(sceneSize: sceneSize)
            let pos = positions[index]
            #expect(
                bounds.contains(pos),
                "Position \(pos) outside \(zone) bounds \(bounds)"
            )
        }
    }

    @Test func elementsSpreadHorizontally() {
        // Place 5 elements in the same zone — their X positions should spread
        // across at least 40% of the zone width.
        let zone = PlacementZone.hilltop
        let specs = (0..<5).map { i in
            ElementSpec(
                entryID: UUID(), elementType: .grass, seed: i + 100,
                phase: .bloom, zone: zone, estimatedNodes: 2
            )
        }
        let positions = PlacementRule.computePositions(for: specs, sceneSize: sceneSize)
        let xs = positions.map(\.x)
        let spread = (xs.max() ?? 0) - (xs.min() ?? 0)
        let zoneBounds = zone.absoluteBounds(sceneSize: sceneSize)
        #expect(
            spread >= zoneBounds.width * 0.4,
            "Horizontal spread \(spread) is less than 40% of zone width \(zoneBounds.width)"
        )
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
