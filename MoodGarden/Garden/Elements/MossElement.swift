import GameplayKit
import SpriteKit

struct MossElement: GardenElement {
    let elementType = ElementType.moss
    let preferredZone = PlacementZone.waterside
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)

        let widthFrac = nextFloat(random, min: 0.6, max: 0.9)
        let sprite = makeImageSprite(named: "elem_moss", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.7, max: 0.95)
        applyGrowthPhase(phase, to: sprite, isImageSprite: true)

        return sprite
    }
}
