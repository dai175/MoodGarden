import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for _ in 0..<patchCount {
            let width = nextFloat(random, min: 0.3, max: 0.6) * cellSize.width
            let height = nextFloat(random, min: 0.2, max: 0.4) * cellSize.height
            let ellipse = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            ellipse.fillColor = MoodType.peaceful.uiColor
            ellipse.strokeColor = .clear
            ellipse.alpha = nextFloat(random, min: 0.5, max: 0.8)
            ellipse.position = CGPoint(
                x: nextFloat(random, min: -0.25, max: 0.25) * cellSize.width,
                y: nextFloat(random, min: -0.25, max: 0.25) * cellSize.height
            )

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: ellipse.alpha * 0.7, duration: nextFloat(random, min: 1.2, max: 1.8)),
                SKAction.fadeAlpha(to: ellipse.alpha, duration: nextFloat(random, min: 1.2, max: 1.8)),
            ])
            ellipse.run(.repeatForever(pulse))

            container.addChild(ellipse)
        }
        return container
    }
}
