import CoreGraphics
import GameplayKit

enum PlacementRule {
    /// Minimum distance between placed elements (in points).
    /// Derived from average element visual radius (~10pt) doubled to prevent overlap.
    static let minimumSpacing: CGFloat = 20

    static func computePositions(for specs: [ElementSpec], sceneSize: CGSize) -> [CGPoint] {
        var grid = SpatialGrid(cellSize: minimumSpacing)
        var positions = Array(repeating: CGPoint.zero, count: specs.count)

        // Group specs by zone, preserving original indices
        var zoneGroups: [PlacementZone: [(index: Int, spec: ElementSpec)]] = [:]
        for (index, spec) in specs.enumerated() {
            zoneGroups[spec.zone, default: []].append((index, spec))
        }

        for (zone, group) in zoneGroups {
            let bounds = zone.absoluteBounds(sceneSize: sceneSize)
            let count = group.count

            // Horizontal slot width for even distribution
            let slotWidth = count > 0 ? bounds.width / CGFloat(count) : bounds.width

            // Y margin: use central 60% of zone height (20% margin top/bottom)
            let yMargin = bounds.height * 0.2
            let yMin = bounds.origin.y + yMargin
            let yRange = bounds.height - yMargin * 2

            for (slotIndex, entry) in group.enumerated() {
                let spec = entry.spec
                let random = GKMersenneTwisterRandomSource(
                    seed: UInt64(bitPattern: Int64(spec.seed))
                )

                let slotMinX = bounds.origin.x + CGFloat(slotIndex) * slotWidth
                let slotBounds = CGRect(
                    x: slotMinX,
                    y: yMin,
                    width: slotWidth,
                    height: max(yRange, 1)
                )

                var placed = false
                for _ in 0..<20 {
                    let candidate = randomPoint(in: slotBounds, using: random)
                    if !grid.hasNeighbor(near: candidate, distance: minimumSpacing) {
                        grid.insert(candidate)
                        positions[entry.index] = candidate
                        placed = true
                        break
                    }
                }

                // Fallback: slot center with spacing check
                if !placed {
                    let center = CGPoint(
                        x: slotMinX + slotWidth / 2,
                        y: yMin + yRange / 2
                    )
                    // Try center and offset positions to avoid collision
                    let offsets: [CGPoint] = [
                        center,
                        CGPoint(x: center.x + minimumSpacing, y: center.y),
                        CGPoint(x: center.x - minimumSpacing, y: center.y),
                        CGPoint(x: center.x, y: center.y + minimumSpacing),
                        CGPoint(x: center.x, y: center.y - minimumSpacing),
                    ]
                    let fallback =
                        offsets.first {
                            !grid.hasNeighbor(near: $0, distance: minimumSpacing)
                        } ?? center  // last resort: place anyway
                    grid.insert(fallback)
                    positions[entry.index] = fallback
                }
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
