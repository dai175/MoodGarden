import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    let elementType = ElementType.moss
    let preferredZone = PlacementZone.waterside
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.6, max: 0.9)
        let sprite = makeImageSprite(named: "elem_moss", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.7, max: 0.95)
        applyGrowthPhase(phase, to: sprite)

        let pulseDuration = nextFloat(random, min: 1.2, max: 1.5) * speed
        sprite.run(.repeatForever(pulseAlpha(from: sprite.alpha, to: sprite.alpha * 0.75, duration: pulseDuration)))

        let scaleUp = SKAction.scale(to: phase.scale * 1.03, duration: nextFloat(random, min: 0.8, max: 1.2) * speed)
        let scaleDown = SKAction.scale(to: phase.scale * 0.97, duration: nextFloat(random, min: 0.8, max: 1.2) * speed)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        sprite.run(.repeatForever(.sequence([scaleUp, scaleDown])))

        return sprite
    }
}
