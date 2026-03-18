import GameplayKit
import SpriteKit

struct FlowerElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()

        let centerRadius = nextFloat(random, min: 0.08, max: 0.12) * cellSize.width
        let center = SKShapeNode(circleOfRadius: centerRadius)
        center.fillColor = MoodType.happy.uiColor
        center.strokeColor = .clear
        container.addChild(center)

        let petalCount = 4 + Int(random.nextInt(upperBound: 3))
        let petalLength = nextFloat(random, min: 0.2, max: 0.35) * cellSize.width
        let petalWidth = petalLength * 0.4
        let hueShift = nextFloat(random, min: -0.05, max: 0.05)

        for index in 0..<petalCount {
            let angle = CGFloat.pi * 2 * CGFloat(index) / CGFloat(petalCount)
            let petal = SKShapeNode(ellipseOf: CGSize(width: petalWidth, height: petalLength))
            petal.fillColor = MoodType.happy.uiColor.withHueOffset(hueShift)
            petal.strokeColor = .clear
            petal.alpha = 0.8
            petal.zRotation = angle
            petal.position = CGPoint(
                x: cos(angle) * petalLength * 0.3,
                y: sin(angle) * petalLength * 0.3
            )
            container.addChild(petal)
        }

        let sway = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 1.5),
            SKAction.rotate(byAngle: -0.05, duration: 1.5),
        ])
        container.run(.repeatForever(sway))

        return container
    }
}
