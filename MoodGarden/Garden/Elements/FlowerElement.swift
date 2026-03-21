import GameplayKit
import SpriteKit

struct FlowerElement: GardenElement {
    let elementType = ElementType.flower
    let preferredZone = PlacementZone.hilltop
    let estimatedNodes = 8

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        let centerRadius = nextFloat(random, min: 0.08, max: 0.12) * cellSize.width
        let center = makeSoftCircle(
            radius: centerRadius,
            color: MoodType.happy.uiColor,
            softness: 0.25
        )
        center.zPosition = 1
        center.setScale(0.9)
        container.addChild(center)

        let glowIn = SKAction.scale(to: 1.15, duration: 1.2 * speed)
        let glowOut = SKAction.scale(to: 0.9, duration: 1.2 * speed)
        glowIn.timingMode = .easeInEaseOut
        glowOut.timingMode = .easeInEaseOut
        center.run(.repeatForever(.sequence([glowIn, glowOut])))

        let petalCount = 4 + Int(random.nextInt(upperBound: 3))
        let petalLength = nextFloat(random, min: 0.2, max: 0.35) * cellSize.width
        let petalWidth = petalLength * 0.4
        let hueShift = nextFloat(random, min: -0.05, max: 0.05)

        for index in 0..<petalCount {
            let angle = CGFloat.pi * 2 * CGFloat(index) / CGFloat(petalCount)
            let petal = makeSoftEllipse(
                size: CGSize(width: petalWidth, height: petalLength),
                color: MoodType.happy.uiColor.withHueOffset(hueShift),
                softness: 0.3
            )
            let baseAlpha = nextFloat(random, min: 0.6, max: 0.9)
            petal.alpha = baseAlpha
            petal.zRotation = angle
            petal.position = CGPoint(
                x: cos(angle) * petalLength * 0.3,
                y: sin(angle) * petalLength * 0.3
            )
            let fadeDuration = nextFloat(random, min: 0.8, max: 1.3) * speed
            let petalPulse = pulseAlpha(from: baseAlpha, to: baseAlpha * 0.6, duration: fadeDuration)
            let petalPhase = SKAction.wait(forDuration: Double(index) * 0.15)
            petal.run(.sequence([petalPhase, .repeatForever(petalPulse)]))

            container.addChild(petal)
        }

        let sway = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 1.5 * speed),
            SKAction.rotate(byAngle: -0.10, duration: 3.0 * speed),
            SKAction.rotate(byAngle: 0.05, duration: 1.5 * speed),
        ])
        container.run(.repeatForever(sway))

        applyGrowthPhase(phase, to: container)
        return container
    }
}
