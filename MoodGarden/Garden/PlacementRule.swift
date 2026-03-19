import CoreGraphics
import GameplayKit

enum PlacementRule {
    static let minimumSpacing: CGFloat = 20

    static func computePositions(for specs: [ElementSpec], sceneSize: CGSize) -> [CGPoint] {
        var positions: [CGPoint] = []

        for spec in specs {
            let random = GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(spec.seed)))
            let bounds = spec.zone.absoluteBounds(sceneSize: sceneSize)
            var placed = false

            // Try up to 20 times to find a non-overlapping position
            for _ in 0..<20 {
                let candidate = randomPoint(in: bounds, using: random)

                let tooClose = positions.contains { existing in
                    hypot(existing.x - candidate.x, existing.y - candidate.y) < minimumSpacing
                }

                if !tooClose {
                    positions.append(candidate)
                    placed = true
                    break
                }
            }

            // Fallback: place anyway if zone is crowded
            if !placed {
                positions.append(randomPoint(in: bounds, using: random))
            }
        }

        return positions
    }

    private static func randomPoint(
        in bounds: CGRect, using random: GKMersenneTwisterRandomSource
    ) -> CGPoint {
        let posX = bounds.origin.x + CGFloat(random.nextUniform()) * bounds.width
        let posY = bounds.origin.y + CGFloat(random.nextUniform()) * bounds.height
        return CGPoint(x: posX, y: posY)
    }
}
