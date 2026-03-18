import GameplayKit
import SpriteKit

struct FogElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for _ in 0..<patchCount {
            let width = nextFloat(random, min: 0.4, max: 0.7) * cellSize.width
            let height = nextFloat(random, min: 0.15, max: 0.3) * cellSize.height
            let fog = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            fog.fillColor = MoodType.anxious.uiColor
            fog.strokeColor = .clear
            fog.alpha = nextFloat(random, min: 0.2, max: 0.4)

            let startX = nextFloat(random, min: -0.3, max: 0.3) * cellSize.width
            fog.position = CGPoint(
                x: startX,
                y: nextFloat(random, min: -0.2, max: 0.2) * cellSize.height
            )

            let drift = nextFloat(random, min: 0.1, max: 0.2) * cellSize.width
            let move = SKAction.sequence([
                SKAction.moveBy(x: drift, y: 0, duration: nextFloat(random, min: 1.2, max: 1.5)),
                SKAction.moveBy(x: -drift, y: 0, duration: nextFloat(random, min: 1.2, max: 1.5)),
            ])
            fog.run(.repeatForever(move))

            container.addChild(fog)
        }
        return container
    }
}
