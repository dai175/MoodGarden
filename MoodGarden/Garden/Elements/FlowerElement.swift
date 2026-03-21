import GameplayKit
import SpriteKit

struct FlowerElement: GardenElement {
    let elementType = ElementType.flower
    let preferredZone = PlacementZone.hilltop
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.6, max: 0.9)
        let sprite = makeImageSprite(named: "elem_flower", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.75, max: 0.95)

        let glowIn = SKAction.scale(to: 1.08, duration: 1.2 * speed)
        let glowOut = SKAction.scale(to: 0.95, duration: 1.2 * speed)
        glowIn.timingMode = .easeInEaseOut
        glowOut.timingMode = .easeInEaseOut
        sprite.run(.repeatForever(.sequence([glowIn, glowOut])))

        let sway = swayRotation(angle: 0.04, duration: 3.0 * speed)
        sprite.run(.repeatForever(sway))

        applyGrowthPhase(phase, to: sprite)
        return sprite
    }
}
