import CoreGraphics
import GameplayKit

enum PlacementRule {
    /// Minimum distance between placed elements (in points).
    /// Derived from average element visual radius (~10pt) doubled to prevent overlap.
    static let minimumSpacing: CGFloat = 20

    static func computePositions(for specs: [ElementSpec], sceneSize: CGSize) -> [CGPoint] {
        var grid = SpatialGrid(cellSize: minimumSpacing)
        var positions: [CGPoint] = []
        positions.reserveCapacity(specs.count)

        for spec in specs {
            let random = GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(spec.seed)))
            let bounds = spec.zone.absoluteBounds(sceneSize: sceneSize)
            var placed = false

            // Try up to 20 times to find a non-overlapping position
            for _ in 0..<20 {
                let candidate = randomPoint(in: bounds, using: random)

                if !grid.hasNeighbor(near: candidate, distance: minimumSpacing) {
                    grid.insert(candidate)
                    positions.append(candidate)
                    placed = true
                    break
                }
            }

            // Fallback: place anyway if zone is crowded
            if !placed {
                let fallback = randomPoint(in: bounds, using: random)
                grid.insert(fallback)
                positions.append(fallback)
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

/// Grid-based spatial hash for O(1) neighbor lookups.
private struct SpatialGrid {
    let cellSize: CGFloat
    private var cells: [CellKey: [CGPoint]] = [:]

    struct CellKey: Hashable {
        let x: Int
        let y: Int
    }

    init(cellSize: CGFloat) {
        self.cellSize = cellSize
    }

    private func cellKey(for point: CGPoint) -> CellKey {
        CellKey(x: Int(floor(point.x / cellSize)), y: Int(floor(point.y / cellSize)))
    }

    mutating func insert(_ point: CGPoint) {
        let key = cellKey(for: point)
        cells[key, default: []].append(point)
    }

    /// Check surrounding 3x3 cells for any point within `distance`.
    func hasNeighbor(near candidate: CGPoint, distance: CGFloat) -> Bool {
        let key = cellKey(for: candidate)
        let distSq = distance * distance

        for dx in -1...1 {
            for dy in -1...1 {
                let neighborKey = CellKey(x: key.x + dx, y: key.y + dy)
                guard let points = cells[neighborKey] else { continue }
                for existing in points {
                    let diffX = existing.x - candidate.x
                    let diffY = existing.y - candidate.y
                    if diffX * diffX + diffY * diffY < distSq {
                        return true
                    }
                }
            }
        }
        return false
    }
}
