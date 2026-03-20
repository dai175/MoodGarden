import GameplayKit

enum MoodAtmosphere {
    private static let supplementaryProbability: Float = 0.5
    private static let seasonBonusProbability: Float = 0.7
    private static let maxSupplementaryCount = 2
    private static let rainbowProbability: Float = 0.6

    /// Elements favored by each season — their supplementary selection probability is boosted.
    private static let seasonalBonuses: [Season: Set<ElementType>] = [
        .spring: [.flower, .butterfly, .grass],
        .summer: [.sunray, .ripple],
        .autumn: [.fallenLeaf, .mushroom, .wind],
        .winter: [.fog, .raindrop, .moss],
    ]

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
                SelectedElement(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
                SelectedElement(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
            ]
        ),
        .happy: (
            base: [
                SelectedElement(elementType: .flower, zone: .hilltop, estimatedNodes: 3),
                SelectedElement(elementType: .sunray, zone: .sky, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .butterfly, zone: .sky, estimatedNodes: 2),
                SelectedElement(elementType: .rainbow, zone: .sky, estimatedNodes: 2),
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
                SelectedElement(elementType: .wind, zone: .sky, estimatedNodes: 2),
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
                SelectedElement(elementType: .fog, zone: .anywhere, estimatedNodes: 2),
            ],
            supplementary: [
                SelectedElement(elementType: .mushroom, zone: .foreground, estimatedNodes: 2),
                SelectedElement(elementType: .moss, zone: .waterside, estimatedNodes: 3),
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
        let bonusElements = seasonalBonuses[season] ?? []

        var selected: [SelectedElement] = []

        // Select 1-2 base elements
        let baseCount =
            pool.base.count == 1
            ? 1 : (1 + random.nextInt(upperBound: 2)).clamped(to: 1...pool.base.count)
        let shuffledBase = shufflePool(pool.base, using: random)
        for index in 0..<baseCount {
            selected.append(shuffledBase[index])
        }

        // Select 0-2 supplementary elements
        // Season-matching elements get boosted probability (0.7 vs 0.5)
        let shuffledSupp = shufflePool(pool.supplementary, using: random)
        var suppCount = 0
        for entry in shuffledSupp where suppCount < maxSupplementaryCount {
            let probability =
                bonusElements.contains(entry.elementType)
                ? seasonBonusProbability : supplementaryProbability
            if random.nextUniform() < probability {
                selected.append(entry)
                suppCount += 1
            }
        }

        // Rainbow detection: sad → happy transition, ~60% chance
        if previousMood == .sad && mood == .happy {
            let rainbowElement = SelectedElement(
                elementType: .rainbow, zone: .sky, estimatedNodes: 2
            )
            if random.nextUniform() < rainbowProbability,
                !selected.contains(where: { $0.elementType == .rainbow })
            {
                selected.append(rainbowElement)
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
