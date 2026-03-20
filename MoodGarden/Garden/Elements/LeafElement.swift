import GameplayKit
import SpriteKit

struct LeafElement: GardenElement {
    let elementType = ElementType.fallenLeaf
    let preferredZone = PlacementZone.foreground
    let estimatedNodes = 2

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()
        let leafCount = 1 + Int(random.nextInt(upperBound: 3))
        let baseColor = MoodType.tired.uiColor

        for _ in 0..<leafCount {
            let width = nextFloat(random, min: 0.15, max: 0.25) * cellSize.width
            let height = width * nextFloat(random, min: 0.5, max: 0.8)
            let leaf = SKShapeNode(ellipseOf: CGSize(width: width, height: height))

            let brownShift = nextFloat(random, min: -0.05, max: 0.05)
            let brightnessScale = nextFloat(random, min: 0.8, max: 1.0)
            leaf.fillColor = baseColor.withHueOffset(brownShift, brightnessMultiplier: brightnessScale)
            leaf.strokeColor = .clear
            leaf.alpha = nextFloat(random, min: 0.6, max: 0.9)
            leaf.zRotation = nextFloat(random, min: 0, max: .pi * 2)
            leaf.position = CGPoint(
                x: nextFloat(random, min: -0.25, max: 0.25) * cellSize.width,
                y: nextFloat(random, min: -0.25, max: 0.25) * cellSize.height
            )

            let rotSpeed = nextFloat(random, min: 1.0, max: 1.5) * speed
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotSpeed * 8)
            let drift = SKAction.sequence([
                SKAction.moveBy(x: 0, y: cellSize.height * 0.05, duration: rotSpeed * 2),
                SKAction.moveBy(x: 0, y: -cellSize.height * 0.05, duration: rotSpeed * 2),
            ])
            leaf.run(.repeatForever(rotate))
            leaf.run(.repeatForever(drift))

            let swayAmount = nextFloat(random, min: 0.04, max: 0.08) * cellSize.width
            let swayDuration = nextFloat(random, min: 0.9, max: 1.4) * speed
            let swayLeft = SKAction.moveBy(x: -swayAmount, y: 0, duration: swayDuration)
            let swayRight = SKAction.moveBy(x: swayAmount, y: 0, duration: swayDuration)
            swayLeft.timingMode = .easeInEaseOut
            swayRight.timingMode = .easeInEaseOut
            leaf.run(.repeatForever(.sequence([swayLeft, swayRight])))

            let leafAlpha = leaf.alpha
            let fadeDown = SKAction.fadeAlpha(
                to: leafAlpha * 0.6, duration: nextFloat(random, min: 1.0, max: 1.5) * speed)
            let fadeUp = SKAction.fadeAlpha(
                to: leafAlpha, duration: nextFloat(random, min: 1.0, max: 1.5) * speed)
            fadeDown.timingMode = .easeInEaseOut
            fadeUp.timingMode = .easeInEaseOut
            leaf.run(.repeatForever(.sequence([fadeDown, fadeUp])))

            container.addChild(leaf)
        }
        applyGrowthPhase(phase, to: container)
        return container
    }
}
