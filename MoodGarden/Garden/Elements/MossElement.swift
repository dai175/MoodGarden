import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for patchIndex in 0..<patchCount {
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

            // alpha パルス（パッチ間の位相差をインデックスで付ける）
            let pulseDuration = nextFloat(random, min: 1.2, max: 1.5)
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: ellipse.alpha * 0.7, duration: pulseDuration),
                SKAction.fadeAlpha(to: ellipse.alpha, duration: pulseDuration),
            ])
            let phaseDelay = SKAction.wait(forDuration: Double(patchIndex) * 0.4)
            ellipse.run(.sequence([phaseDelay, .repeatForever(pulse)]))

            // 微細スケール変化 (0.97-1.03)
            let scaleUp = SKAction.scale(to: 1.03, duration: nextFloat(random, min: 0.8, max: 1.2))
            let scaleDown = SKAction.scale(to: 0.97, duration: nextFloat(random, min: 0.8, max: 1.2))
            scaleUp.timingMode = .easeInEaseOut
            scaleDown.timingMode = .easeInEaseOut
            let scalePulse = SKAction.sequence([scaleUp, scaleDown])
            ellipse.run(.repeatForever(scalePulse))

            container.addChild(ellipse)
        }
        return container
    }
}
