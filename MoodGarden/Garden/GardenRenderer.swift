import SpriteKit

struct GardenRenderer {
    private static let elementMap: [MoodType: any GardenElement] = [
        .peaceful: MossElement(),
        .happy: FlowerElement(),
        .energetic: GrassElement(),
        .anxious: FogElement(),
        .sad: RainElement(),
        .angry: WindElement(),
        .tired: LeafElement(),
    ]

    func createNode(for data: GardenElementData, cellSize: CGSize) -> SKNode {
        // swiftlint:disable:next force_unwrapping
        let element = Self.elementMap[data.mood]!
        let node = element.createNode(seed: data.seed, cellSize: cellSize)
        node.name = "element_day_\(data.day)"
        return node
    }

    func createNodes(
        for entries: [GardenElementData],
        layout: GardenGridLayout
    ) -> [(node: SKNode, position: CGPoint)] {
        entries.map { entry in
            let node = createNode(for: entry, cellSize: layout.cellSize)
            let position = layout.position(forDay: entry.day)
            return (node: node, position: position)
        }
    }
}
