import GameplayKit
import SpriteKit

struct MushroomElement: GardenElement {
    let elementType = ElementType.mushroom
    let preferredZone = PlacementZone.foreground
    let estimatedNodes = 2

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        // Stem — small rectangle
        let stemWidth = nextFloat(random, min: 0.04, max: 0.07) * cellSize.width
        let stemHeight = nextFloat(random, min: 0.12, max: 0.2) * cellSize.height
        let stem = SKShapeNode(rectOf: CGSize(width: stemWidth, height: stemHeight), cornerRadius: stemWidth * 0.3)
        stem.fillColor = MoodType.tired.uiColor
        stem.strokeColor = .clear
        stem.alpha = nextFloat(random, min: 0.6, max: 0.8)
        stem.position = CGPoint(x: 0, y: -stemHeight * 0.3)
        container.addChild(stem)

        // Cap — wider ellipse on top
        let capWidth = nextFloat(random, min: 0.12, max: 0.2) * cellSize.width
        let capHeight = capWidth * nextFloat(random, min: 0.5, max: 0.7)
        let cap = SKShapeNode(ellipseOf: CGSize(width: capWidth, height: capHeight))
        let hueShift = nextFloat(random, min: -0.05, max: 0.05)
        cap.fillColor = MoodType.tired.uiColor.withHueOffset(hueShift)
        cap.strokeColor = .clear
        cap.alpha = nextFloat(random, min: 0.7, max: 0.9)
        cap.position = CGPoint(x: 0, y: stemHeight * 0.15)
        cap.zPosition = 1
        container.addChild(cap)

        applyGrowthPhase(phase, to: container)

        // Subtle scale pulse — breathing effect (relative to growth phase scale)
        let baseScale = phase.scale
        let pulseDuration = nextFloat(random, min: 2.0, max: 3.5) * speed
        let pulseUp = SKAction.scale(to: baseScale * 1.04, duration: pulseDuration)
        let pulseDown = SKAction.scale(to: baseScale * 0.97, duration: pulseDuration)
        pulseUp.timingMode = .easeInEaseOut
        pulseDown.timingMode = .easeInEaseOut
        container.run(.repeatForever(.sequence([pulseUp, pulseDown])))
        return container
    }
}
