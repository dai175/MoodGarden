import GameplayKit
import SpriteKit

struct FogElement: GardenElement {
    let elementType = ElementType.fog
    let preferredZone = PlacementZone.anywhere
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.8, max: 1.2)
        let sprite = makeImageSprite(named: "elem_fog", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.25, max: 0.45)
        applyGrowthPhase(phase, to: sprite)

        let driftX = nextFloat(random, min: 0.08, max: 0.15) * cellSize.width
        let driftY = nextFloat(random, min: 0.02, max: 0.05) * cellSize.height
        let moveDuration = nextFloat(random, min: 1.5, max: 2.0) * speed
        sprite.run(.repeatForever(driftAction(dx: driftX, dy: driftY, duration: moveDuration)))

        let fadeDuration = nextFloat(random, min: 1.0, max: 1.5) * speed
        sprite.run(.repeatForever(pulseAlpha(from: sprite.alpha, to: sprite.alpha * 0.5, duration: fadeDuration)))

        return sprite
    }
}
