import GameplayKit
import SpriteKit

struct LeafElement: GardenElement {
    let elementType = ElementType.fallenLeaf
    let preferredZone = PlacementZone.foreground
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.5, max: 0.8)
        let sprite = makeImageSprite(named: "elem_fallenLeaf", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.7, max: 0.9)
        sprite.zRotation = nextFloat(random, min: -0.3, max: 0.3)
        applyGrowthPhase(phase, to: sprite)

        let sway = swayRotation(angle: 0.03, duration: 3.0 * speed)
        sprite.run(.repeatForever(sway))

        let swayAmount = nextFloat(random, min: 0.02, max: 0.05) * cellSize.width
        let swayDuration = nextFloat(random, min: 1.2, max: 1.8) * speed
        sprite.run(.repeatForever(driftAction(dx: swayAmount, dy: 0, duration: swayDuration)))

        let fadeDuration = nextFloat(random, min: 1.0, max: 1.5) * speed
        sprite.run(.repeatForever(pulseAlpha(from: sprite.alpha, to: sprite.alpha * 0.7, duration: fadeDuration)))

        return sprite
    }
}
