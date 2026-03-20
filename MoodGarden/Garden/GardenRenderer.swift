import SpriteKit

struct GardenRenderer {
    private static let elementMap: [ElementType: any GardenElement] = [
        .moss: MossElement(),
        .flower: FlowerElement(),
        .grass: GrassElement(),
        .fog: FogElement(),
        .raindrop: RainElement(),
        .wind: WindElement(),
        .fallenLeaf: LeafElement(),
        .butterfly: ButterflyElement(),
        .sunray: SunrayElement(),
        .rainbow: RainbowElement(),
        .puddle: PuddleElement(),
        .ripple: RippleElement(),
        .vine: VineElement(),
        .mushroom: MushroomElement(),
    ]

    func createNode(for spec: ElementSpec, sceneSize: CGSize) -> SKNode {
        let element = Self.elementMap[spec.elementType]
        let node =
            element?.createNode(seed: spec.seed, phase: spec.phase, sceneSize: sceneSize) ?? SKNode()
        node.name = "element_\(spec.elementType.rawValue)_\(spec.seed)"
        return node
    }

    func createNodes(
        for specs: [ElementSpec], positions: [CGPoint], sceneSize: CGSize
    ) -> [(node: SKNode, position: CGPoint)] {
        zip(specs, positions).map { spec, position in
            let node = createNode(for: spec, sceneSize: sceneSize)
            return (node: node, position: position)
        }
    }
}
