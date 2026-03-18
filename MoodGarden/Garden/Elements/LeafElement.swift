import GameplayKit
import SpriteKit

struct LeafElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let leafCount = 1 + Int(random.nextInt(upperBound: 3))

        for _ in 0..<leafCount {
            let width = nextFloat(random, min: 0.15, max: 0.25) * cellSize.width
            let height = width * nextFloat(random, min: 0.5, max: 0.8)
            let leaf = SKShapeNode(ellipseOf: CGSize(width: width, height: height))

            let brownShift = nextFloat(random, min: -0.05, max: 0.05)
            let baseColor = MoodType.tired.uiColor
            var hue: CGFloat = 0
            var sat: CGFloat = 0
            var bri: CGFloat = 0
            var alp: CGFloat = 0
            baseColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alp)
            leaf.fillColor = UIColor(
                hue: hue + brownShift,
                saturation: sat,
                brightness: bri * nextFloat(random, min: 0.8, max: 1.0),
                alpha: 1
            )
            leaf.strokeColor = .clear
            leaf.alpha = nextFloat(random, min: 0.6, max: 0.9)
            leaf.zRotation = nextFloat(random, min: 0, max: .pi * 2)
            leaf.position = CGPoint(
                x: nextFloat(random, min: -0.25, max: 0.25) * cellSize.width,
                y: nextFloat(random, min: -0.25, max: 0.25) * cellSize.height
            )

            let rotSpeed = nextFloat(random, min: 1.0, max: 1.5)
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotSpeed * 8)
            let drift = SKAction.sequence([
                SKAction.moveBy(x: 0, y: cellSize.height * 0.05, duration: rotSpeed * 2),
                SKAction.moveBy(x: 0, y: -cellSize.height * 0.05, duration: rotSpeed * 2),
            ])
            leaf.run(.repeatForever(rotate))
            leaf.run(.repeatForever(drift))

            container.addChild(leaf)
        }
        return container
    }
}
