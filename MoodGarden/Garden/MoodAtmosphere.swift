import GameplayKit

enum MoodAtmosphere {
    private static let supplementaryProbability: Float = 0.5
    private static let maxSupplementaryCount = 2

    struct SelectedElement: Equatable {
        let elementType: ElementType
        let zone: PlacementZone
        let estimatedNodes: Int
    }

    private static let pools: [MoodType: (base: [SelectedElement], supplementary: [SelectedElement])] = [
        .peaceful: (
            base: [
                SelectedElement(elementType: .moss, zone: .waterside, estimatedNodes: 3),
                SelectedElement(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
                SelectedElement(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
                SelectedElement(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .happy: (
            base: [
                SelectedElement(elementType: .flower, zone: .hilltop, estimatedNodes: 3),
                SelectedElement(elementType: .warmLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                SelectedElement(elementType: .butterfly, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .breeze, zone: .sky, estimatedNodes: 1),
                SelectedElement(elementType: .shimmer, zone: .anywhere, estimatedNodes: 1),
            ]
        ),
        .energetic: (
            base: [
                SelectedElement(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
                SelectedElement(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .sunray, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .wind, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .flower, zone: .foreground, estimatedNodes: 3),
            ]
        ),
        .anxious: (
            base: [
                SelectedElement(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                SelectedElement(elementType: .vine, zone: .foreground, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
                SelectedElement(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                SelectedElement(elementType: .fog, zone: .sky, estimatedNodes: 2),
            ]
        ),
        .sad: (
            base: [
                SelectedElement(elementType: .raindrop, zone: .sky, estimatedNodes: 3),
                SelectedElement(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .puddle, zone: .foreground, estimatedNodes: 2),
                SelectedElement(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
                SelectedElement(elementType: .dimLight, zone: .sky, estimatedNodes: 1),
            ]
        ),
        .angry: (
            base: [
                SelectedElement(elementType: .wind, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .grass, zone: .hilltop, estimatedNodes: 3),
            ],
            supplementary: [
                SelectedElement(elementType: .ripple, zone: .waterside, estimatedNodes: 2),
                SelectedElement(elementType: .fog, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .wind, zone: .foreground, estimatedNodes: 2),
            ]
        ),
        .tired: (
            base: [
                SelectedElement(elementType: .fallenLeaf, zone: .foreground, estimatedNodes: 2),
                SelectedElement(elementType: .dimLight, zone: .anywhere, estimatedNodes: 1),
            ],
            supplementary: [
                SelectedElement(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
                SelectedElement(elementType: .shimmer, zone: .waterside, estimatedNodes: 1),
                SelectedElement(elementType: .pebble, zone: .foreground, estimatedNodes: 1),
            ]
        ),
    ]

    static func selectElements(
        mood: MoodType,
        seed: Int
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
            selected.append(shuffledBase[index])
        }

        // Select 0-2 supplementary elements (50% chance each)
        let shuffledSupp = shufflePool(pool.supplementary, using: random)
        var suppCount = 0
        for entry in shuffledSupp where suppCount < maxSupplementaryCount {
            if random.nextUniform() < supplementaryProbability {
                selected.append(entry)
                suppCount += 1
            }
        }

        // Ensure minimum of 2 elements
        if selected.count < 2,
            let fallback = pool.supplementary.first(where: { !selected.contains($0) })
                ?? pool.supplementary.first
        {
            selected.append(fallback)
        }

        return selected
    }

    private static func shufflePool(
        _ pool: [SelectedElement], using random: GKMersenneTwisterRandomSource
    ) -> [SelectedElement] {
        (random.arrayByShufflingObjects(in: pool) as? [SelectedElement]) ?? pool
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
