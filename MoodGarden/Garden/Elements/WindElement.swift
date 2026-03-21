import GameplayKit
import SpriteKit

struct WindElement: GardenElement {
    let elementType = ElementType.wind
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.7, max: 1.0)
        let sprite = makeImageSprite(named: "elem_wind", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.3, max: 0.55)
        applyGrowthPhase(phase, to: sprite)

        let drift = nextFloat(random, min: 0.12, max: 0.25) * cellSize.width
        let moveDuration = nextFloat(random, min: 0.8, max: 1.3) * speed
        sprite.run(.repeatForever(driftAction(dx: drift, dy: drift * 0.2, duration: moveDuration)))

        let baseAlpha = sprite.alpha
        let gustUp = SKAction.fadeAlpha(to: min(baseAlpha * 1.4, 0.7), duration: 0.6 * speed)
        gustUp.timingMode = .easeInEaseOut
        let gustDown = SKAction.fadeAlpha(to: baseAlpha * 0.4, duration: 0.8 * speed)
        gustDown.timingMode = .easeInEaseOut
        let gustRestore = SKAction.fadeAlpha(to: baseAlpha, duration: 0.6 * speed)
        gustRestore.timingMode = .easeInEaseOut
        sprite.run(.repeatForever(.sequence([gustUp, gustDown, gustRestore])))

        return sprite
    }
}
