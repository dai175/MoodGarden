import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    let elementType = ElementType.moss
    let preferredZone = PlacementZone.waterside
    let estimatedNodes = 3

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for patchIndex in 0..<patchCount {
            let width = nextFloat(random, min: 0.3, max: 0.6) * cellSize.width
            let height = nextFloat(random, min: 0.2, max: 0.4) * cellSize.height
            let ellipse = makeSoftEllipse(
                size: CGSize(width: width, height: height),
                color: MoodType.peaceful.uiColor,
                softness: 0.35
            )
            ellipse.alpha = nextFloat(random, min: 0.5, max: 0.8)

            ellipse.position = CGPoint(
                x: nextFloat(random, min: -0.25, max: 0.25) * cellSize.width,
                y: nextFloat(random, min: -0.25, max: 0.25) * cellSize.height
            )

            let pulseDuration = nextFloat(random, min: 1.2, max: 1.5) * speed
            let pulse = pulseAlpha(from: ellipse.alpha, to: ellipse.alpha * 0.7, duration: pulseDuration)
            let phaseDelay = SKAction.wait(forDuration: Double(patchIndex) * 0.4)
            ellipse.run(.sequence([phaseDelay, .repeatForever(pulse)]))

            let scaleUp = SKAction.scale(to: 1.03, duration: nextFloat(random, min: 0.8, max: 1.2) * speed)
            let scaleDown = SKAction.scale(to: 0.97, duration: nextFloat(random, min: 0.8, max: 1.2) * speed)
            scaleUp.timingMode = .easeInEaseOut
            scaleDown.timingMode = .easeInEaseOut
            let scalePulse = SKAction.sequence([scaleUp, scaleDown])
            ellipse.run(.repeatForever(scalePulse))

            container.addChild(ellipse)
        }
        applyGrowthPhase(phase, to: container)
        return container
    }
}
