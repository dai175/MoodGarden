import GameplayKit
import SpriteKit

struct WindElement: GardenElement {
    let elementType = ElementType.wind
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)

        let widthFrac = nextFloat(random, min: 0.7, max: 1.0)
        let sprite = makeImageSprite(named: "elem_wind", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.3, max: 0.55)
        applyGrowthPhase(phase, to: sprite, isImageSprite: true)

        return sprite
    }
}
