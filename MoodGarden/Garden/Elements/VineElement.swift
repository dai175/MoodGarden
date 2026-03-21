import CoreGraphics
import GameplayKit
import SpriteKit

struct VineElement: GardenElement {
    let elementType = ElementType.vine
    let preferredZone = PlacementZone.foreground
    let estimatedNodes = 4

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        // Curved vine stem (kept as SKShapeNode — line-based)
        let stemHeight = nextFloat(random, min: 0.35, max: 0.55) * cellSize.height
        let curvature = nextFloat(random, min: -0.15, max: 0.15) * cellSize.width
        let stemPath = CGMutablePath()
        stemPath.move(to: CGPoint(x: 0, y: -stemHeight / 2))
        stemPath.addQuadCurve(
            to: CGPoint(x: curvature * 0.5, y: stemHeight / 2),
            control: CGPoint(x: curvature, y: 0)
        )

        let stem = SKShapeNode(path: stemPath)
        stem.strokeColor = MoodType.peaceful.uiColor
        stem.lineWidth = nextFloat(random, min: 1.5, max: 2.5)
        stem.lineCap = .round
        stem.fillColor = .clear
        stem.alpha = nextFloat(random, min: 0.6, max: 0.85)
        container.addChild(stem)

        // Small leaves along the vine — soft-edged
        let leafCount = 2 + Int(random.nextInt(upperBound: 2))
        let hueShift = nextFloat(random, min: -0.04, max: 0.04)

        for index in 0..<leafCount {
            let t = CGFloat(index + 1) / CGFloat(leafCount + 1)
            let leafY = -stemHeight / 2 + stemHeight * t
            let leafX = curvature * (2 * t - t * t)

            let leafSize = nextFloat(random, min: 0.04, max: 0.07) * cellSize.width
            let leaf = makeSoftEllipse(
                size: CGSize(width: leafSize, height: leafSize * 1.6),
                color: MoodType.energetic.uiColor.withHueOffset(hueShift),
                softness: 0.3
            )
            leaf.alpha = nextFloat(random, min: 0.6, max: 0.8)
            leaf.position = CGPoint(x: leafX, y: leafY)

            let side: CGFloat = random.nextBool() ? 1 : -1
            leaf.zRotation = side * nextFloat(random, min: 0.3, max: 0.6)

            container.addChild(leaf)
        }

        // Gentle sway rotation
        let swayAngle = nextFloat(random, min: 0.03, max: 0.07)
        let swayDuration = nextFloat(random, min: 2.0, max: 3.5) * speed
        container.run(.repeatForever(swayRotation(angle: swayAngle, duration: swayDuration)))

        applyGrowthPhase(phase, to: container)
        return container
    }
}
