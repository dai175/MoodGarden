import GameplayKit
import SpriteKit

struct GrassElement: GardenElement {
    let elementType = ElementType.grass
    let preferredZone = PlacementZone.hilltop
    let estimatedNodes = 3

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
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

            let delayBase = nextFloat(random, min: 0.0, max: 0.5)
            let delay = SKAction.wait(forDuration: Double(index) * 0.15 + delayBase)
            let sway = swayRotation(angle: 0.08, duration: 2.0 * speed)
            blade.run(.sequence([delay, .repeatForever(sway)]))

            let tipFadeDuration = nextFloat(random, min: 0.8, max: 1.1) * speed
            let tipShiver = pulseAlpha(from: blade.alpha, to: blade.alpha * 0.75, duration: tipFadeDuration)
            let shiverDelay = SKAction.wait(forDuration: Double(index) * 0.25)
            blade.run(.sequence([shiverDelay, .repeatForever(tipShiver)]))

            container.addChild(blade)
        }
        applyGrowthPhase(phase, to: container)
        return container
    }
}
