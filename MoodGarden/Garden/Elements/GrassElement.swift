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

            // delay をランダムに調整（以前の固定 index * 0.2 より自然な揺れに）
            let delayBase = nextFloat(random, min: 0.0, max: 0.5)
            let delay = SKAction.wait(forDuration: Double(index) * 0.15 + delayBase)
            let sway = SKAction.sequence([
                SKAction.rotate(byAngle: 0.08, duration: 1.0),
                SKAction.rotate(byAngle: -0.08, duration: 1.0),
            ])
            blade.run(.sequence([delay, .repeatForever(sway)]))

            // ブレード先端の微震え（alpha 変動で表現）
            let tipShiverDuration = nextFloat(random, min: 0.8, max: 1.1)
            let tipAlphaLow = blade.alpha * 0.75
            let fadeOut = SKAction.fadeAlpha(to: tipAlphaLow, duration: tipShiverDuration * 0.5)
            fadeOut.timingMode = .easeInEaseOut
            let fadeIn = SKAction.fadeAlpha(to: blade.alpha, duration: tipShiverDuration * 0.5)
            fadeIn.timingMode = .easeInEaseOut
            let tipShiver = SKAction.sequence([fadeOut, fadeIn])
            let shiverDelay = SKAction.wait(forDuration: Double(index) * 0.25)
            blade.run(.sequence([shiverDelay, .repeatForever(tipShiver)]))

            container.addChild(blade)
        }
        return container
    }
}
