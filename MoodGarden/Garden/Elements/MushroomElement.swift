import GameplayKit
import SpriteKit

struct MushroomElement: GardenElement {
    let elementType = ElementType.mushroom
    let preferredZone = PlacementZone.foreground
    let estimatedNodes = 2

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let container = SKNode()

        // Stem — small rectangle (kept as SKShapeNode, small element)
        let stemWidth = nextFloat(random, min: 0.04, max: 0.07) * cellSize.width
        let stemHeight = nextFloat(random, min: 0.12, max: 0.2) * cellSize.height
        let stem = SKShapeNode(rectOf: CGSize(width: stemWidth, height: stemHeight), cornerRadius: stemWidth * 0.3)
        stem.fillColor = MoodType.tired.uiColor
        stem.strokeColor = .clear
        stem.alpha = nextFloat(random, min: 0.6, max: 0.8)
        stem.position = CGPoint(x: 0, y: -stemHeight * 0.3)
        container.addChild(stem)

        // Cap — soft-edged ellipse on top
        let capWidth = nextFloat(random, min: 0.12, max: 0.2) * cellSize.width
        let capHeight = capWidth * nextFloat(random, min: 0.5, max: 0.7)
        let hueShift = nextFloat(random, min: -0.05, max: 0.05)
        let cap = makeSoftEllipse(
            size: CGSize(width: capWidth, height: capHeight),
            color: MoodType.tired.uiColor.withHueOffset(hueShift),
            softness: 0.3
        )
        cap.alpha = nextFloat(random, min: 0.7, max: 0.9)
        cap.position = CGPoint(x: 0, y: stemHeight * 0.15)
        cap.zPosition = 1
        container.addChild(cap)

        applyGrowthPhase(phase, to: container)

        return container
    }
}
