import GameplayKit

enum MoodAtmosphere {
    struct SelectedElement: Equatable {
        let elementType: ElementType
        let zone: PlacementZone
        let estimatedNodes: Int
    }

    private struct PoolEntry {
        let elementType: ElementType
        let zone: PlacementZone
        let estimatedNodes: Int
    }

    private static let pools: [MoodType: (base: [PoolEntry], supplementary: [PoolEntry])] = [
        .peaceful: (
            base: [
                PoolEntry(elementType: .moss, zone: .waterside, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
                PoolEntry(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
                PoolEntry(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .happy: (
            base: [
                PoolEntry(elementType: .flower, zone: .hilltop, estimatedNodes: 3),
                PoolEntry(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                PoolEntry(elementType: .butterfly, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .breeze, zone: .sky, estimatedNodes: 1),
                PoolEntry(elementType: .shimmer, zone: .anywhere, estimatedNodes: 1),
            ]
        ),
        .energetic: (
            base: [
                PoolEntry(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .sunray, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .wind, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .flower, zone: .foreground, estimatedNodes: 3),
            ]
        ),
        .anxious: (
            base: [
                PoolEntry(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                PoolEntry(elementType: .vine, zone: .foreground, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
                PoolEntry(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                PoolEntry(elementType: .fog, zone: .sky, estimatedNodes: 2),
            ]
        ),
        .sad: (
            base: [
                PoolEntry(elementType: .raindrop, zone: .sky, estimatedNodes: 3),
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                PoolEntry(elementType: .puddle, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                PoolEntry(elementType: .dimLight, zone: .sky, estimatedNodes: 1),
            ]
        ),
        .angry: (
            base: [
                PoolEntry(elementType: .wind, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
            ],
            supplementary: [
                PoolEntry(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
                PoolEntry(elementType: .fog, zone: .sky, estimatedNodes: 2),
                PoolEntry(elementType: .wind, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .tired: (
            base: [
                PoolEntry(elementType: .fallenLeaf, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                PoolEntry(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
                PoolEntry(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                PoolEntry(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
            ]
        ),
    ]

    static func selectElements(
        mood: MoodType,
        seed: Int,
        season: Season,
        previousMood: MoodType?
    ) -> [SelectedElement] {
        guard let pool = pools[mood] else { return [] }
        let random = GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))

        var selected: [SelectedElement] = []

        // Select 1-2 base elements
        let baseCount =
            pool.base.count == 1
            ? 1 : (1 + random.nextInt(upperBound: 2)).clamped(to: 1...pool.base.count)
        let shuffledBase = shufflePool(pool.base, using: random)
        for index in 0..<baseCount {
            let entry = shuffledBase[index]
            selected.append(
                SelectedElement(
                    elementType: entry.elementType, zone: entry.zone,
                    estimatedNodes: entry.estimatedNodes
                ))
        }

        // Select 0-2 supplementary elements (50% chance each)
        let shuffledSupp = shufflePool(pool.supplementary, using: random)
        var suppCount = 0
        for entry in shuffledSupp where suppCount < 2 {
            if random.nextUniform() > 0.5 {
                selected.append(
                    SelectedElement(
                        elementType: entry.elementType, zone: entry.zone,
                        estimatedNodes: entry.estimatedNodes
                    ))
                suppCount += 1
            }
        }

        // Ensure minimum of 2 elements
        if selected.count < 2, let fallback = pool.supplementary.first {
            selected.append(
                SelectedElement(
                    elementType: fallback.elementType, zone: fallback.zone,
                    estimatedNodes: fallback.estimatedNodes
                ))
        }

        return selected
    }

    private static func shufflePool(
        _ pool: [PoolEntry], using random: GKMersenneTwisterRandomSource
    ) -> [PoolEntry] {
        (random.arrayByShufflingObjects(in: pool) as? [PoolEntry]) ?? pool
    }
}

extension Comparable {
    fileprivate func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
