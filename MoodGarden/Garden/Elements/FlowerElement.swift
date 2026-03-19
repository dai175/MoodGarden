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
        center.zPosition = 1
        container.addChild(center)

        // 中心のグロー効果（スケールパルス）
        let glowIn = SKAction.scale(to: 1.15, duration: 1.2)
        let glowOut = SKAction.scale(to: 0.9, duration: 1.2)
        glowIn.timingMode = .easeInEaseOut
        glowOut.timingMode = .easeInEaseOut
        center.run(.repeatForever(.sequence([glowIn, glowOut])))

        let petalCount = 4 + Int(random.nextInt(upperBound: 3))
        let petalLength = nextFloat(random, min: 0.2, max: 0.35) * cellSize.width
        let petalWidth = petalLength * 0.4
        let hueShift = nextFloat(random, min: -0.05, max: 0.05)

        for index in 0..<petalCount {
            let angle = CGFloat.pi * 2 * CGFloat(index) / CGFloat(petalCount)
            let petal = SKShapeNode(ellipseOf: CGSize(width: petalWidth, height: petalLength))
            petal.fillColor = MoodType.happy.uiColor.withHueOffset(hueShift)
            petal.strokeColor = .clear
            // 花弁個別の alpha 変動（位相差付き）
            let baseAlpha = nextFloat(random, min: 0.6, max: 0.9)
            petal.alpha = baseAlpha
            petal.zRotation = angle
            petal.position = CGPoint(
                x: cos(angle) * petalLength * 0.3,
                y: sin(angle) * petalLength * 0.3
            )
            let fadeDown = SKAction.fadeAlpha(to: baseAlpha * 0.6, duration: nextFloat(random, min: 0.8, max: 1.3))
            let fadeUp = SKAction.fadeAlpha(to: baseAlpha, duration: nextFloat(random, min: 0.8, max: 1.3))
            fadeDown.timingMode = .easeInEaseOut
            fadeUp.timingMode = .easeInEaseOut
            let petalPhase = SKAction.wait(forDuration: Double(index) * 0.15)
            petal.run(.sequence([petalPhase, .repeatForever(.sequence([fadeDown, fadeUp]))]))

            container.addChild(petal)
        }

        let sway = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 1.5),
            SKAction.rotate(byAngle: -0.10, duration: 3.0),
            SKAction.rotate(byAngle: 0.05, duration: 1.5),
        ])
        container.run(.repeatForever(sway))

        return container
    }
}
