import GameplayKit
import SpriteKit

struct ButterflyElement: GardenElement {
    let elementType = ElementType.butterfly
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 3

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        // Body — thin vertical line
        let bodyHeight = nextFloat(random, min: 0.12, max: 0.18) * cellSize.height
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: 0, y: bodyHeight / 2))
        bodyPath.addLine(to: CGPoint(x: 0, y: -bodyHeight / 2))
        let body = SKShapeNode(path: bodyPath)
        body.strokeColor = MoodType.happy.uiColor
        body.lineWidth = 1.5
        body.zPosition = 1
        container.addChild(body)

        // Wings — two ellipses mirrored horizontally
        let wingWidth = nextFloat(random, min: 0.15, max: 0.22) * cellSize.width
        let wingHeight = nextFloat(random, min: 0.10, max: 0.16) * cellSize.height
        let hueShift = nextFloat(random, min: -0.06, max: 0.06)
        let wingAlpha = nextFloat(random, min: 0.6, max: 0.85)

        for side: CGFloat in [-1, 1] {
            let wing = SKShapeNode(ellipseOf: CGSize(width: wingWidth, height: wingHeight))
            wing.fillColor = MoodType.happy.uiColor.withHueOffset(hueShift * side)
            wing.strokeColor = .clear
            wing.alpha = wingAlpha
            wing.position = CGPoint(x: side * wingWidth * 0.45, y: bodyHeight * 0.1)

            // Wing flap — scaleY oscillation
            let flapDuration = nextFloat(random, min: 0.3, max: 0.5) * speed
            let flapDown = SKAction.scaleY(to: 0.3, duration: flapDuration)
            let flapUp = SKAction.scaleY(to: 1.0, duration: flapDuration)
            flapDown.timingMode = .easeInEaseOut
            flapUp.timingMode = .easeInEaseOut
            wing.run(.repeatForever(.sequence([flapDown, flapUp])))

            container.addChild(wing)
        }

        // Drift path — gentle wandering movement
        let driftX = nextFloat(random, min: 0.1, max: 0.25) * cellSize.width
        let driftY = nextFloat(random, min: 0.05, max: 0.15) * cellSize.height
        let driftDuration = nextFloat(random, min: 2.0, max: 3.5) * speed
        container.run(.repeatForever(driftAction(dx: driftX, dy: driftY, duration: driftDuration)))

        applyGrowthPhase(phase, to: container)
        return container
    }
}
