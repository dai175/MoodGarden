import GameplayKit
import SpriteKit

struct RainElement: GardenElement {
    let elementType = ElementType.raindrop
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)

        let widthFrac = nextFloat(random, min: 0.5, max: 0.8)
        let sprite = makeImageSprite(named: "elem_raindrop", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.6, max: 0.85)
        applyGrowthPhase(phase, to: sprite, isImageSprite: true)

        let fallDistance = cellSize.height * 0.3
        let duration = nextFloat(random, min: 1.0, max: 1.5) * speed
        let fall = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -fallDistance, duration: duration),
            SKAction.fadeOut(withDuration: 0.3 * speed),
            SKAction.moveBy(x: 0, y: fallDistance, duration: 0),
            SKAction.fadeAlpha(to: sprite.alpha, duration: 0.5 * speed),
        ])
        sprite.run(.repeatForever(fall))

        return sprite
    }
}
