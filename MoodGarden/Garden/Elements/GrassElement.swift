import GameplayKit
import SpriteKit

struct GrassElement: GardenElement {
    let elementType = ElementType.grass
    let preferredZone = PlacementZone.hilltop
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.6, max: 0.9)
        let sprite = makeImageSprite(named: "elem_grass", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.7, max: 0.9)

        let sway = swayRotation(angle: 0.06, duration: 2.5 * speed)
        sprite.run(.repeatForever(sway))

        let fadeDuration = nextFloat(random, min: 0.8, max: 1.2) * speed
        sprite.run(.repeatForever(pulseAlpha(from: sprite.alpha, to: sprite.alpha * 0.8, duration: fadeDuration)))

        applyGrowthPhase(phase, to: sprite)
        return sprite
    }
}
