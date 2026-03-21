import GameplayKit
import SpriteKit

struct SunrayElement: GardenElement {
    let elementType = ElementType.sunray
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 3

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        let rayCount = 2 + Int(random.nextInt(upperBound: 2))
        let baseAngle = nextFloat(random, min: -0.4, max: 0.4)

        for index in 0..<rayCount {
            let length = nextFloat(random, min: 0.3, max: 0.55) * cellSize.height
            let width = nextFloat(random, min: 0.02, max: 0.04) * cellSize.width
            let ray = makeSoftEllipseWithGlow(
                size: CGSize(width: width, height: length),
                color: MoodType.happy.uiColor,
                softness: 0.35,
                glowRadius: 3,
                glowColor: MoodType.happy.uiColor.withAlphaComponent(0.4)
            )
            ray.alpha = nextFloat(random, min: 0.3, max: 0.55)
            ray.blendMode = .add

            let spreadAngle = nextFloat(random, min: 0.1, max: 0.25) * CGFloat(index - rayCount / 2)
            ray.zRotation = baseAngle + spreadAngle
            ray.position = CGPoint(
                x: nextFloat(random, min: -0.1, max: 0.1) * cellSize.width,
                y: nextFloat(random, min: -0.05, max: 0.05) * cellSize.height
            )

            // Alpha pulse
            let baseAlpha = ray.alpha
            let pulseDuration = nextFloat(random, min: 1.5, max: 2.5) * speed
            let rayPulse = pulseAlpha(
                from: min(baseAlpha * 1.6, 0.7), to: baseAlpha * 0.5, duration: pulseDuration)
            let phaseDelay = SKAction.wait(forDuration: Double(index) * 0.5)
            ray.run(.sequence([phaseDelay, .repeatForever(rayPulse)]))

            // Gentle rotation
            let rotAmount = nextFloat(random, min: 0.03, max: 0.08)
            let rotDuration = nextFloat(random, min: 3.0, max: 5.0) * speed
            ray.run(.repeatForever(swayRotation(angle: rotAmount, duration: rotDuration)))

            container.addChild(ray)
        }

        applyGrowthPhase(phase, to: container)
        return container
    }
}
