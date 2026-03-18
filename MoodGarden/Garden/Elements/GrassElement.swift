import GameplayKit
import SpriteKit

struct GrassElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let bladeCount = 3 + Int(random.nextInt(upperBound: 3))

        for index in 0..<bladeCount {
            let height = nextFloat(random, min: 0.3, max: 0.6) * cellSize.height
            let width = nextFloat(random, min: 0.06, max: 0.12) * cellSize.width
            let tilt = nextFloat(random, min: -0.3, max: 0.3)

            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: -width / 2, y: 0))
            path.addLine(to: CGPoint(x: tilt * width, y: height))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
            path.closeSubpath()

            let blade = SKShapeNode(path: path)
            blade.fillColor = MoodType.energetic.uiColor
            blade.strokeColor = .clear
            blade.alpha = nextFloat(random, min: 0.6, max: 0.9)

            let spread = cellSize.width * 0.6
            blade.position = CGPoint(
                x: nextFloat(random, min: -0.5, max: 0.5) * spread,
                y: -cellSize.height * 0.25
            )

            let delay = SKAction.wait(forDuration: Double(index) * 0.2)
            let sway = SKAction.sequence([
                SKAction.rotate(byAngle: 0.08, duration: 1.0),
                SKAction.rotate(byAngle: -0.08, duration: 1.0),
            ])
            blade.run(.sequence([delay, .repeatForever(sway)]))

            container.addChild(blade)
        }
        return container
    }
}
